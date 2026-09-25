import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/core/utils/formatters.dart';
import 'package:solomatch/features/notifications/domain/app_notification.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_notifications.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

AppNotification note(String id, {bool read = false, String? matchId = 'm1'}) =>
    AppNotification(
      id: id,
      type: 'request_accepted',
      title: "You're in! ⚽",
      body: 'Your request to join Saturday Night Football was accepted.',
      matchId: matchId,
      read: read,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

void main() {
  late FakeNotificationRepository inbox;
  late FakePushMessaging push;
  late FakeAuthRepository auth;

  setUp(() {
    inbox = FakeNotificationRepository();
    push = FakePushMessaging();
    auth = FakeAuthRepository(signedIn: testUser);
  });

  Future<void> pump(WidgetTester tester, {FakeAuthRepository? as}) => pumpApp(
    tester,
    auth: as ?? auth,
    profiles: FakeProfileRepository(profiles: [testProfile()]),
    matches: FakeMatchRepository(matches: [testMatch()]),
    notifications: inbox,
    push: push,
  );

  test('relative times', () {
    final now = DateTime(2026, 9, 25, 12);
    expect(
      Formatters.relative(now.subtract(const Duration(seconds: 20)), now),
      'just now',
    );
    expect(
      Formatters.relative(now.subtract(const Duration(minutes: 5)), now),
      '5 min ago',
    );
    expect(
      Formatters.relative(now.subtract(const Duration(hours: 3)), now),
      '3 h ago',
    );
    expect(
      Formatters.relative(now.subtract(const Duration(days: 1)), now),
      'yesterday',
    );
  });

  testWidgets('signing in asks permission and registers this phone', (
    tester,
  ) async {
    await pump(tester);
    expect(push.permissionRequested, isTrue);
    expect(inbox.devices['raj'], {'token-1'});

    // FCM rotates the token → the new one is stored too.
    push.refresh.add('token-2');
    await tester.pumpAndSettle();
    expect(inbox.devices['raj'], {'token-1', 'token-2'});
  });

  testWidgets('signing out unregisters the phone first', (tester) async {
    await pump(tester);
    await tester.tapVisible(find.bySemanticsLabel('Profile'));
    await tester.tapVisible(find.byKey(const Key('signOutButton')));

    expect(inbox.devices['raj'], isEmpty);
    expect(push.tokenDeleted, isTrue);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('bell shows unread count live; inbox opens the match', (
    tester,
  ) async {
    inbox.add(note('old', read: true));
    await pump(tester);
    expect(find.text('1'), findsNothing);

    inbox.add(note('n1'));
    inbox.add(note('n2'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('notificationBell')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );

    await tester.tapVisible(find.byKey(const Key('notificationBell')));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('5 min ago'), findsNWidgets(3));

    await tester.tapVisible(find.byKey(const Key('notification_n1')));
    expect(inbox.inbox.firstWhere((n) => n.id == 'n1').read, isTrue);
    expect(find.byKey(const Key('rosterCount')), findsOneWidget); // match page
  });

  testWidgets('mark all read clears the badge', (tester) async {
    inbox
      ..add(note('n1'))
      ..add(note('n2'));
    await pump(tester);
    await tester.tapVisible(find.byKey(const Key('notificationBell')));
    await tester.tapVisible(find.byKey(const Key('markAllReadButton')));

    expect(inbox.inbox.every((n) => n.read), isTrue);
    expect(find.byKey(const Key('markAllReadButton')), findsNothing);
  });

  testWidgets('push while the app is open → snackbar with View', (
    tester,
  ) async {
    await pump(tester);
    push.foreground.add((
      title: 'New join request',
      body: 'Amit Karki wants to play goalkeeper.',
      route: '/matches/m1',
    ));
    await tester.pumpAndSettle();

    expect(
      find.text('New join request\nAmit Karki wants to play goalkeeper.'),
      findsOneWidget,
    );
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rosterCount')), findsOneWidget);
  });

  testWidgets('tapping a notification (app in background) opens the match', (
    tester,
  ) async {
    await pump(tester);
    push.opened.add((title: 'x', body: 'y', route: '/matches/m1'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rosterCount')), findsOneWidget);
  });

  testWidgets('launched from a notification → opens after sign-in', (
    tester,
  ) async {
    push.launchedFrom = (title: 'x', body: 'y', route: '/matches/m1');
    await pump(tester);
    expect(find.byKey(const Key('rosterCount')), findsOneWidget);
  });

  testWidgets('no permission/token still works (inbox only)', (tester) async {
    push.token = null;
    await pump(tester);
    expect(inbox.devices['raj'], isNull);
    expect(find.text('Find your next match ⚽'), findsOneWidget);
  });
}
