import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/match_requests/domain/join_request.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

const matchTitle = '⚽ Saturday Night Football';

/// The same fake backend, viewed as one signed-in user.
Future<void> pumpAs(
  WidgetTester tester,
  String uid, {
  required FakeMatchRepository matches,
  required FakeMatchRequestRepository requests,
}) => pumpApp(
  tester,
  auth: FakeAuthRepository(signedIn: testUser.copyWith(uid: uid)),
  profiles: FakeProfileRepository(
    profiles: [
      testProfile(),
      testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki'),
    ],
  ),
  matches: matches,
  requests: requests,
);

Future<void> openMatch(WidgetTester tester) =>
    tester.tapVisible(find.text(matchTitle));

void main() {
  late FakeMatchRepository matches;
  late FakeMatchRequestRepository requests;

  setUp(() {
    matches = FakeMatchRepository(matches: [testMatch(currentPlayers: 7)]);
    requests = FakeMatchRequestRepository(matches);
  });

  testWidgets('player requests to join → Request Pending', (tester) async {
    await pumpAs(tester, 'amit', matches: matches, requests: requests);
    await openMatch(tester);

    await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
    // Sheet suggests the player's own position group (CM → MID).
    expect(find.text('Request to join'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('requestMessageField')),
      'Can play in goal too',
    );
    await tester.tapVisible(find.byKey(const Key('sendRequestButton')));

    final request = requests.requestOf('m1', 'amit')!;
    expect(request.status, RequestStatus.pending);
    expect(request.preferredGroup, PositionGroup.mid);
    expect(request.message, 'Can play in goal too');
    expect(find.byKey(const Key('requestPendingButton')), findsOneWidget);
  });

  testWidgets(
    'organizer accepts on another device → player sees "You\'re in! ⚽" '
    'and 7/10 → 8/10 without refreshing',
    (tester) async {
      await pumpAs(tester, 'amit', matches: matches, requests: requests);
      await openMatch(tester);
      await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
      await tester.tapVisible(find.byKey(const Key('sendRequestButton')));

      Text count() => tester.widget<Text>(find.byKey(const Key('rosterCount')));
      expect(count().data, '7/10');

      // The organizer's Cloud Function runs elsewhere.
      await requests.accept('m1', 'amit');
      await tester.pumpAndSettle();

      expect(find.text("You're in! ⚽"), findsOneWidget);
      expect(find.byKey(const Key('playingButton')), findsOneWidget);
      expect(count().data, '8/10');
      expect(find.text('Amit Karki'), findsOneWidget); // listed on roster
    },
  );

  testWidgets('rejected player sees the decision and cannot re-request', (
    tester,
  ) async {
    await pumpAs(tester, 'amit', matches: matches, requests: requests);
    await openMatch(tester);
    await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
    await tester.tapVisible(find.byKey(const Key('sendRequestButton')));

    await requests.reject('m1', 'amit');
    await tester.pumpAndSettle();

    expect(
      find.text("Your request wasn't accepted this time."),
      findsOneWidget,
    );
    expect(find.text('Request declined'), findsOneWidget);
    expect(find.byKey(const Key('requestToJoinButton')), findsNothing);
    expect(
      matches.matchOf('m1')!.currentPlayers,
      7,
      reason: 'roster unchanged',
    );
  });

  testWidgets('player can withdraw a pending request', (tester) async {
    await pumpAs(tester, 'amit', matches: matches, requests: requests);
    await openMatch(tester);
    await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
    await tester.tapVisible(find.byKey(const Key('sendRequestButton')));

    await tester.tapVisible(find.byKey(const Key('withdrawButton')));
    expect(requests.requestOf('m1', 'amit')!.status, RequestStatus.cancelled);
    expect(find.byKey(const Key('requestToJoinButton')), findsOneWidget);
  });

  testWidgets('accepted player can leave; the place reopens', (tester) async {
    await pumpAs(tester, 'amit', matches: matches, requests: requests);
    await openMatch(tester);
    await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
    await tester.tapVisible(find.byKey(const Key('sendRequestButton')));
    await requests.accept('m1', 'amit');
    await tester.pumpAndSettle();

    await tester.tapVisible(find.byKey(const Key('leaveButton')));
    await tester.tapVisible(find.widgetWithText(FilledButton, 'Leave match'));

    expect(matches.matchOf('m1')!.currentPlayers, 7);
    expect(find.byKey(const Key('requestToJoinButton')), findsOneWidget);
  });

  testWidgets('organizer reviews requests and accepts one live', (
    tester,
  ) async {
    await requests.requestToJoin(
      match: matches.matchOf('m1')!,
      player: testProfile(
        uid: 'amit',
        username: 'amit',
        fullName: 'Amit Karki',
      ),
      preferredGroup: PositionGroup.gk,
      message: 'Keeper here',
    );
    await pumpAs(tester, 'raj', matches: matches, requests: requests);
    await openMatch(tester);

    // Badge shows 1 pending request.
    expect(find.text('1'), findsOneWidget);
    await tester.tapVisible(find.byKey(const Key('manageRequestsButton')));

    expect(find.text('Amit Karki'), findsOneWidget);
    expect(find.text('"Keeper here"'), findsOneWidget);
    expect(find.textContaining('wants 🧤 GK'), findsOneWidget);
    expect(find.text('7/10 players · 3 spots left'), findsOneWidget);

    await tester.tapVisible(find.byKey(const Key('accept_amit')));

    expect(find.text('Player added to the roster ⚽'), findsOneWidget);
    expect(find.text('No pending requests'), findsOneWidget);
    expect(find.text('8/10 players · 2 spots left'), findsOneWidget);
    expect(matches.matchOf('m1')!.slots[PositionGroup.gk].filled, 1);
  });

  testWidgets('organizer rejects a request; roster unchanged', (tester) async {
    await requests.requestToJoin(
      match: matches.matchOf('m1')!,
      player: testProfile(
        uid: 'amit',
        username: 'amit',
        fullName: 'Amit Karki',
      ),
      preferredGroup: PositionGroup.mid,
    );
    await pumpAs(tester, 'raj', matches: matches, requests: requests);
    await openMatch(tester);
    await tester.tapVisible(find.byKey(const Key('manageRequestsButton')));

    await tester.tapVisible(find.byKey(const Key('reject_amit')));
    expect(requests.requestOf('m1', 'amit')!.status, RequestStatus.rejected);
    expect(matches.matchOf('m1')!.currentPlayers, 7);
  });

  testWidgets('server refusal (match full) is shown to the organizer', (
    tester,
  ) async {
    await requests.requestToJoin(
      match: matches.matchOf('m1')!,
      player: testProfile(
        uid: 'amit',
        username: 'amit',
        fullName: 'Amit Karki',
      ),
      preferredGroup: PositionGroup.mid,
    );
    requests.acceptError = const ValidationFailure('This match is full.');
    await pumpAs(tester, 'raj', matches: matches, requests: requests);
    await openMatch(tester);
    await tester.tapVisible(find.byKey(const Key('manageRequestsButton')));

    await tester.tapVisible(find.byKey(const Key('accept_amit')));
    expect(find.text('This match is full.'), findsOneWidget);
    expect(find.byKey(const Key('accept_amit')), findsOneWidget);
  });

  testWidgets('taking the last place turns the match full for others', (
    tester,
  ) async {
    matches.push(testMatch(currentPlayers: 9, status: MatchStatus.filling));
    await pumpAs(tester, 'amit', matches: matches, requests: requests);
    await openMatch(tester);
    expect(find.byKey(const Key('requestToJoinButton')), findsOneWidget);

    // Someone else fills the final spot.
    await requests.requestToJoin(
      match: matches.matchOf('m1')!,
      player: testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai'),
      preferredGroup: PositionGroup.any,
    );
    await requests.accept('m1', 'sita');
    await tester.pumpAndSettle();

    expect(find.text('Match Full'), findsOneWidget);
    expect(find.byKey(const Key('requestToJoinButton')), findsNothing);
  });
}
