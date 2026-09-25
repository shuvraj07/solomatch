import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solomatch/features/match_requests/data/firestore_match_request_repository.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/join_request.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/data/firestore_match_repository.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/my_matches/data/firestore_my_matches_repository.dart';
import 'package:solomatch/features/my_matches/domain/my_match_entry.dart';
import 'package:solomatch/features/profile/domain/player_stats.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_my_matches_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/seed_match.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

final now = DateTime(2026, 9, 25, 12);

MyMatchEntry entry(
  String id, {
  MyMatchRole role = MyMatchRole.player,
  RequestStatus? status = RequestStatus.accepted,
  int dayOffset = 1,
}) => MyMatchEntry(
  matchId: id,
  role: role,
  title: 'Match $id',
  startAt: now.add(Duration(days: dayOffset)),
  requestStatus: role == MyMatchRole.organizer ? null : status,
);

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  group('categorizeMyMatches', () {
    test('sorts entries into the right tabs', () {
      final tabs = categorizeMyMatches([
        entry('playing', dayOffset: 2),
        entry('organizing', role: MyMatchRole.organizer, dayOffset: 1),
        entry('pending', status: RequestStatus.pending),
        entry('declined', status: RequestStatus.rejected),
        entry('withdrawn', status: RequestStatus.cancelled),
        entry('played', dayOffset: -3),
        entry('organized', role: MyMatchRole.organizer, dayOffset: -1),
        entry('staleRequest', status: RequestStatus.pending, dayOffset: -1),
      ], now);

      List<String> ids(MyMatchesTab t) => [for (final e in tabs[t]!) e.matchId];

      expect(ids(MyMatchesTab.upcoming), ['organizing', 'playing']);
      expect(ids(MyMatchesTab.requested), ['pending']);
      expect(ids(MyMatchesTab.played), ['organized', 'played']);
      expect(ids(MyMatchesTab.created), ['organizing', 'organized']);
    });

    test('one entry per match, preferring the organizer view', () {
      final tabs = categorizeMyMatches([
        entry('m1'),
        entry('m1', role: MyMatchRole.organizer),
      ], now);
      expect(tabs[MyMatchesTab.upcoming]!.single.role, MyMatchRole.organizer);
    });
  });

  test('Firestore: organized matches and my requests are combined', () async {
    final db = FakeFirebaseFirestore();
    final matches = FirestoreMatchRepository(
      db,
      _MockStorage(),
      _MockFunctions(),
    );
    final requests = FirestoreMatchRequestRepository(db, _MockFunctions());

    await seedMatch(db, completeDraft(id: 'mine'), testOrganizer);
    await seedMatch(
      db,
      completeDraft(id: 'theirs'),
      testOrganizer.copyWith(uid: 'sita', username: 'sita'),
    );
    final theirs = (await matches
        .watchMatch('theirs')
        .firstWhere((m) => m != null))!;
    await requests.requestToJoin(
      match: theirs,
      player: testProfile(),
      preferredGroup: PositionGroup.mid,
    );

    final list = await FirestoreMyMatchesRepository(db)
        .watchMyMatches('raj')
        .firstWhere((l) => l.length == 2);
    final byId = {for (final e in list) e.matchId: e};
    expect(byId['mine']!.role, MyMatchRole.organizer);
    expect(byId['theirs']!.role, MyMatchRole.player);
    expect(byId['theirs']!.requestStatus, RequestStatus.pending);
    expect(byId['theirs']!.title, 'Saturday Night Football');
  });

  group('screens', () {
    late FakeMatchRepository matches;
    late FakeMatchRequestRepository requests;
    late FakeProfileRepository profiles;

    setUp(() {
      matches = FakeMatchRepository(
        matches: [
          testMatch(id: 'm1', currentPlayers: 1),
          testMatch(id: 'm2', organizerUid: 'sita'),
          testMatch(id: 'm3', status: MatchStatus.completed),
        ],
      );
      requests = FakeMatchRequestRepository(matches)
        ..seedRoster('m1', [
          RosterEntry(
            player: MatchRequestMapper.cardFromProfile(
              testProfile(
                uid: 'amit',
                username: 'amit',
                fullName: 'Amit Karki',
              ),
            ),
            group: PositionGroup.mid,
          ),
        ]);
      profiles = FakeProfileRepository(
        profiles: [
          testProfile(),
          testProfile(
            uid: 'amit',
            username: 'amit',
            fullName: 'Amit Karki',
          ).copyWith(
            bio: 'Box-to-box midfielder',
            stats: const PlayerStats(gamesPlayed: 28, goals: 11, motmAwards: 3),
          ),
          testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai'),
        ],
      );
    });

    Future<void> pump(WidgetTester tester, FakeMyMatchesRepository mine) =>
        pumpApp(
          tester,
          auth: FakeAuthRepository(signedIn: testUser),
          profiles: profiles,
          matches: matches,
          requests: requests,
          myMatches: mine,
        );

    testWidgets('My matches: tabs, live status and opening a match', (
      tester,
    ) async {
      final mine = FakeMyMatchesRepository([
        MyMatchEntry(
          matchId: 'm2',
          role: MyMatchRole.player,
          title: 'Saturday Night Football',
          startAt: DateTime.now().add(const Duration(days: 2)),
          requestStatus: RequestStatus.pending,
        ),
        MyMatchEntry(
          matchId: 'm3',
          role: MyMatchRole.organizer,
          title: 'Saturday Night Football',
          startAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      await pump(tester, mine);

      await tester.tapVisible(find.byKey(const Key('homeMyMatchesButton')));
      expect(find.text('Requested (1)'), findsOneWidget);
      expect(find.text('Played (1)'), findsOneWidget);
      expect(find.text('Nothing coming up'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('tab_requested')));
      expect(find.text('⏳ Request pending'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('tab_played')));
      expect(find.text('📋 You organize this match'), findsOneWidget);
      expect(find.text('Played'), findsWidgets); // live status chip

      // Organizer's request gets accepted elsewhere → moves tabs live.
      mine.set([
        mine.entries.first.copyWith(requestStatus: RequestStatus.accepted),
        mine.entries.last,
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Upcoming (1)'), findsOneWidget);

      await tester.tapVisible(find.text('📋 You organize this match'));
      expect(find.byKey(const Key('rosterCount')), findsOneWidget);
    });

    testWidgets('tap a roster player → their public profile', (tester) async {
      await pump(tester, FakeMyMatchesRepository());
      await tester.tapVisible(find.text('⚽ Saturday Night Football').first);

      await tester.tapVisible(find.byKey(const Key('rosterPlayer_amit')));
      expect(find.text('Amit Karki'), findsOneWidget);
      expect(find.text('Box-to-box midfielder'), findsOneWidget);
      expect(find.text('⚽ 11'), findsOneWidget);
      expect(find.text('🏆 3'), findsOneWidget);
      // Private data is never shown.
      expect(find.textContaining('1998'), findsNothing);
      expect(find.byKey(const Key('signOutButton')), findsNothing);
    });

    testWidgets('tap the organizer → their profile', (tester) async {
      await pump(tester, FakeMyMatchesRepository());
      // m2 is organized by Sita (listed second, same kick-off time).
      await tester.tapVisible(find.text('⚽ Saturday Night Football').at(1));
      await tester.tapVisible(find.byKey(const Key('organizerLink')));
      expect(find.text('Sita Rai'), findsOneWidget);
      expect(find.text('Player'), findsOneWidget); // app bar
    });

    testWidgets('own profile has a My matches button', (tester) async {
      await pump(tester, FakeMyMatchesRepository());
      await tester.tapVisible(find.bySemanticsLabel('Profile'));
      await tester.tapVisible(find.byKey(const Key('myMatchesButton')));
      expect(find.text('My matches'), findsOneWidget);
    });
  });
}
