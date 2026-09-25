import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/features/chat/domain/chat_models.dart';
import 'package:solomatch/features/safety/domain/safety_repository.dart';
import 'package:solomatch/features/settings/domain/settings_repository.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_chat_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/fake_settings_safety.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

final sita = testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai');

void main() {
  late FakeProfileRepository profiles;
  late FakeSettingsRepository settings;
  late FakeSafetyRepository safety;
  late FakeAuthRepository auth;

  setUp(() {
    profiles = FakeProfileRepository(profiles: [testProfile(), sita]);
    settings = FakeSettingsRepository();
    safety = FakeSafetyRepository();
    auth = FakeAuthRepository(signedIn: testUser);
  });

  Future<void> pump(WidgetTester tester, {FakeChatRepository? chat}) => pumpApp(
    tester,
    auth: auth,
    profiles: profiles,
    matches: FakeMatchRepository(matches: [testMatch(organizerUid: 'sita')]),
    settings: settings,
    safety: safety,
    chat: chat,
  );

  Future<void> go(WidgetTester tester, String route) async {
    unawaited(
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('edit profile saves changes', (tester) async {
    await pump(tester);
    await tester.tapVisible(find.bySemanticsLabel('Profile'));
    await tester.tapVisible(find.byKey(const Key('editProfileButton')));

    await tester.enterText(find.byKey(const Key('editCity')), 'Lalitpur');
    await tester.enterText(find.byKey(const Key('editBio')), 'Box-to-box');
    await tester.tapVisible(find.byKey(const Key('saveProfileButton')));

    final saved = profiles.profileOf('raj')!;
    expect(saved.city, 'Lalitpur');
    expect(saved.bio, 'Box-to-box');
    expect(saved.username, 'raj10');
    expect(find.text('@raj10 · Lalitpur'), findsOneWidget);
  });

  testWidgets('edit profile rejects an empty name', (tester) async {
    await pump(tester);
    await go(tester, AppRoutes.editProfile);
    await tester.enterText(find.byKey(const Key('editFullName')), ' ');
    await tester.tapVisible(find.byKey(const Key('saveProfileButton')));
    expect(find.text('Enter your name'), findsOneWidget);
    expect(profiles.profileOf('raj')!.fullName, 'Raj Shrestha');
  });

  testWidgets('notification toggles save per category', (tester) async {
    await pump(tester);
    await tester.tapVisible(find.bySemanticsLabel('Profile'));
    await tester.tapVisible(find.byKey(const Key('settingsButton')));
    await tester.tapVisible(find.byKey(const Key('pref_chat')));
    expect(settings.prefs[NotificationCategory.chat], isFalse);
    expect(settings.prefs[NotificationCategory.matches], isTrue);
  });

  testWidgets('hide city: others see only @username', (tester) async {
    profiles = FakeProfileRepository(
      profiles: [testProfile(), sita.copyWith(hideCity: true)],
    );
    await pump(tester);
    await go(tester, AppRoutes.playerProfile('sita'));
    expect(find.text('@sita'), findsOneWidget);
    expect(find.textContaining('Kathmandu'), findsNothing);
  });

  testWidgets(
    'block from profile hides their chat messages; unblock in settings',
    (tester) async {
      final chat = FakeChatRepository([
        const Conversation(
          id: 'match_m1',
          type: ConversationType.group,
          matchId: 'm1',
          title: 'Saturday Night Football',
          participantIds: ['raj', 'sita'],
          participants: {'sita': ChatMember(name: 'Sita Rai')},
        ),
      ])..receive('match_m1', 'sita', 'Rude message');
      await pump(tester, chat: chat);

      await go(tester, AppRoutes.playerProfile('sita'));
      await tester.tapVisible(find.byKey(const Key('playerMenu')));
      await tester.tapVisible(find.text('Block'));
      await tester.tapVisible(find.byKey(const Key('confirmBlockButton')));
      expect(safety.blocked, {'sita': 'Sita Rai'});

      await go(tester, AppRoutes.chat('match_m1'));
      expect(find.text('Rude message'), findsNothing);

      await go(tester, AppRoutes.blockedPlayers);
      expect(find.text('Sita Rai'), findsOneWidget);
      await tester.tapVisible(find.text('Unblock'));
      expect(safety.blocked, isEmpty);
    },
  );

  testWidgets('report a player with a reason', (tester) async {
    await pump(tester);
    await go(tester, AppRoutes.playerProfile('sita'));
    await tester.tapVisible(find.byKey(const Key('playerMenu')));
    await tester.tapVisible(find.text('Report player'));
    await tester.tapVisible(find.byKey(const Key('reason_noShow')));
    await tester.enterText(
      find.byKey(const Key('reportDetailsField')),
      'Twice',
    );
    await tester.tapVisible(find.byKey(const Key('submitReportButton')));

    final r = safety.reports.single;
    expect(r.type, ReportTarget.player);
    expect(r.targetId, 'sita');
    expect(r.reason, ReportReason.noShow);
    expect(r.details, 'Twice');
  });

  testWidgets('no report/block menu on your own profile', (tester) async {
    await pump(tester);
    await go(tester, AppRoutes.playerProfile('raj'));
    expect(find.byKey(const Key('playerMenu')), findsNothing);
  });

  testWidgets('report a match from its page', (tester) async {
    await pump(tester);
    await tester.tapVisible(find.text('⚽ Saturday Night Football'));
    await tester.tapVisible(find.byKey(const Key('matchReportMenu')));
    await tester.tapVisible(find.text('Report match'));
    await tester.tapVisible(find.byKey(const Key('reason_fake')));
    await tester.tapVisible(find.byKey(const Key('submitReportButton')));
    expect(safety.reports.single.type, ReportTarget.match);
  });

  testWidgets('delete account needs DELETE typed, then signs out', (
    tester,
  ) async {
    await pump(tester);
    await go(tester, AppRoutes.settings);
    await tester.tapVisible(find.byKey(const Key('deleteAccountTile')));

    final button = find.byKey(const Key('confirmDeleteButton'));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('deleteConfirmField')),
      'delete',
    );
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(settings.deleted, isTrue);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('info pages open', (tester) async {
    await pump(tester);
    await go(tester, AppRoutes.settings);
    await tester.tapVisible(find.text('Community guidelines'));
    expect(find.textContaining('Show up.'), findsOneWidget);
  });
}
