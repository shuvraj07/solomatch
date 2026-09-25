import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/position_slots.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_match_repository.dart';
import '../../../fakes/fake_profile_repository.dart';
import '../../../fakes/match_test_data.dart';
import '../../../fakes/test_data.dart';
import '../../../helpers/pump_app.dart';

/// Signed in as Amit (a player, not the organizer) unless [asOrganizer].
Future<void> pumpWithMatches(
  WidgetTester tester,
  FakeMatchRepository matches, {
  bool asOrganizer = false,
}) {
  final uid = asOrganizer ? 'raj' : 'amit';
  final user = testUser.copyWith(uid: uid);
  return pumpApp(
    tester,
    auth: FakeAuthRepository(signedIn: user),
    profiles: FakeProfileRepository(
      profiles: [testProfile(uid: uid, username: uid)],
    ),
    matches: matches,
  );
}

void main() {
  testWidgets('Home lists upcoming matches and opens details', (tester) async {
    await pumpWithMatches(tester, FakeMatchRepository(matches: [testMatch()]));

    expect(find.text('⚽ Saturday Night Football'), findsOneWidget);
    expect(find.textContaining('0/10 players'), findsOneWidget);
    expect(find.text('🧤 1 GK'), findsOneWidget);

    await tester.tapVisible(find.text('⚽ Saturday Night Football'));
    expect(find.byKey(const Key('rosterCount')), findsOneWidget);
    expect(find.byKey(const Key('requestToJoinButton')), findsOneWidget);
  });

  testWidgets('Home shows an empty state', (tester) async {
    await pumpWithMatches(tester, FakeMatchRepository());
    expect(find.text('No matches yet'), findsOneWidget);
  });

  testWidgets('match details update live: 7/10 → 8/10 → full', (tester) async {
    final repo = FakeMatchRepository(
      matches: [testMatch(currentPlayers: 7, status: MatchStatus.filling)],
    );
    await pumpWithMatches(tester, repo);
    await tester.tapVisible(find.text('⚽ Saturday Night Football'));

    Text count() => tester.widget<Text>(find.byKey(const Key('rosterCount')));
    expect(count().data, '7/10');
    expect(find.text('3 spots remaining'), findsOneWidget);

    // Another device accepts a player: no refresh, the screen follows.
    repo.push(testMatch(currentPlayers: 8, status: MatchStatus.filling));
    await tester.pumpAndSettle();
    expect(count().data, '8/10');
    expect(find.text('2 spots remaining'), findsOneWidget);

    repo.push(testMatch(currentPlayers: 10, status: MatchStatus.full));
    await tester.pumpAndSettle();
    expect(count().data, '10/10');
    expect(find.text('Match Full'), findsOneWidget);
    expect(find.byKey(const Key('requestToJoinButton')), findsNothing);
  });

  testWidgets('roster shows filled/needed per position', (tester) async {
    const slots = PositionSlots({
      PositionGroup.gk: (needed: 1, filled: 1),
      PositionGroup.def: (needed: 2, filled: 2),
      PositionGroup.mid: (needed: 2, filled: 1),
      PositionGroup.fwd: (needed: 1, filled: 0),
      PositionGroup.any: (needed: 4, filled: 3),
    });
    await pumpWithMatches(
      tester,
      FakeMatchRepository(
        matches: [testMatch(currentPlayers: 7, slots: slots)],
      ),
    );
    await tester.tapVisible(find.text('⚽ Saturday Night Football'));

    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
    expect(find.text('3 spots remaining'), findsOneWidget);
  });

  testWidgets('organizer can cancel their match', (tester) async {
    final repo = FakeMatchRepository(matches: [testMatch()]);
    await pumpWithMatches(tester, repo, asOrganizer: true);
    await tester.tapVisible(find.text('⚽ Saturday Night Football'));

    expect(find.text("You're organizing this match"), findsOneWidget);
    await tester.tapVisible(find.byKey(const Key('matchMenu')));
    await tester.tapVisible(find.text('Cancel match').last);
    await tester.tapVisible(find.widgetWithText(FilledButton, 'Cancel match'));

    expect(repo.matchOf('m1')!.status, MatchStatus.cancelled);
    expect(find.text('Match cancelled'), findsOneWidget);
  });

  testWidgets('create flow: new match, validation, then step 2', (
    tester,
  ) async {
    final repo = FakeMatchRepository();
    await pumpWithMatches(tester, repo, asOrganizer: true);

    await tester.tapVisible(find.byKey(const Key('createMatchButton')));
    await tester.tapVisible(find.byKey(const Key('newMatchButton')));
    expect(find.text('Step 1 of 15'), findsOneWidget);

    await tester.tapVisible(find.byKey(const Key('createMatchNextButton')));
    expect(find.text('Give the match a name'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('matchTitleField')),
      'Friday Futsal',
    );
    await tester.tapVisible(find.byKey(const Key('createMatchNextButton')));
    expect(find.text('Step 2 of 15'), findsOneWidget);
    // City is prefilled from the organizer's profile.
    expect(find.text('Kathmandu'), findsOneWidget);

    await tester.tapVisible(find.byKey(const Key('saveDraftButton')));
    expect(repo.drafts.values.single.title, 'Friday Futsal');
  });
}
