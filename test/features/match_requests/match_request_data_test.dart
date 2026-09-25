import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solomatch/features/match_requests/data/firestore_match_request_repository.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/join_request.dart';
import 'package:solomatch/features/matches/domain/match_action.dart';
import 'package:solomatch/features/profile/domain/player_stats.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

void main() {
  // Registers the fake FieldValue implementation before any test builds a
  // document containing FieldValue.serverTimestamp().
  setUpAll(FakeFirebaseFirestore.new);

  group('request document', () {
    test('player card mirrors the profile (what security rules check)', () {
      final profile = testProfile().copyWith(
        stats: const PlayerStats(
          gamesPlayed: 28,
          ratingAvg: 4.8,
          ratingCount: 12,
        ),
      );
      final doc = MatchRequestMapper.newRequest(
        match: testMatch(),
        player: profile,
        preferredGroup: PositionGroup.mid,
        message: '  hi  ',
      );
      expect(doc['status'], 'pending');
      expect(doc['message'], 'hi');
      expect(doc['player'], {
        'uid': 'raj',
        'name': 'Raj Shrestha',
        'username': 'raj10',
        'photoUrl': null,
        'primaryPosition': 'centralMidfielder',
        'secondaryPositions': ['attackingMidfielder'],
        'skillLevel': 'intermediate',
        'ratingAvg': 4.8,
        'ratingCount': 12,
        'gamesPlayed': 28,
      });
      expect((doc['match'] as Map)['venueName'], 'Dhuku Futsal');
    });
  });

  group('FirestoreMatchRequestRepository', () {
    late FakeFirebaseFirestore db;
    late FirestoreMatchRequestRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = FirestoreMatchRequestRepository(db, _MockFunctions());
    });

    test('request → watchMyRequest and pending list; withdraw', () async {
      await repo.requestToJoin(
        match: testMatch(),
        player: testProfile(uid: 'amit', username: 'amit'),
        preferredGroup: PositionGroup.gk,
      );
      final mine = await repo
          .watchMyRequest('m1', 'amit')
          .firstWhere((r) => r != null);
      expect(mine!.status, RequestStatus.pending);
      expect(mine.preferredGroup, PositionGroup.gk);
      expect(mine.player.username, 'amit');

      final pending = await repo
          .watchPendingRequests('m1')
          .firstWhere((l) => l.isNotEmpty);
      expect(pending.single.playerId, 'amit');

      await repo.withdrawRequest('m1', 'amit');
      expect(await repo.watchPendingRequests('m1').first, isEmpty);
    });

    test('roster entries written by the server are read back', () async {
      final card = MatchRequestMapper.cardTo(
        MatchRequestMapper.cardFromProfile(testProfile()),
      );
      await db.doc('matches/m1/roster/raj').set({
        'player': card,
        'group': 'mid',
        'joinedAt': DateTime(2026, 9, 25),
      });
      final roster = await repo
          .watchRoster('m1')
          .firstWhere((l) => l.isNotEmpty);
      expect(roster.single.group, PositionGroup.mid);
      expect(roster.single.player.name, 'Raj Shrestha');
    });
  });

  group('resolveMatchAction with requests', () {
    JoinRequest req(RequestStatus s) => JoinRequest(
      matchId: 'm1',
      player: MatchRequestMapper.cardFromProfile(testProfile(uid: 'amit')),
      preferredGroup: PositionGroup.mid,
      status: s,
    );

    test('maps request states to actions', () {
      final m = testMatch();
      expect(
        resolveMatchAction(m, 'amit', myRequest: req(RequestStatus.pending)),
        MatchAction.pending,
      );
      expect(
        resolveMatchAction(m, 'amit', myRequest: req(RequestStatus.accepted)),
        MatchAction.playing,
      );
      expect(
        resolveMatchAction(m, 'amit', myRequest: req(RequestStatus.rejected)),
        MatchAction.declined,
      );
      expect(
        resolveMatchAction(m, 'amit', myRequest: req(RequestStatus.cancelled)),
        MatchAction.requestToJoin,
      );
    });

    test('an accepted player still sees "playing" when the match is full', () {
      expect(
        resolveMatchAction(
          testMatch(currentPlayers: 10),
          'amit',
          myRequest: req(RequestStatus.accepted),
        ),
        MatchAction.playing,
      );
    });
  });
}
