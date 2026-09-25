import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solomatch/features/matches/data/firestore_match_repository.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../../fakes/match_test_data.dart';
import '../../../helpers/seed_match.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreMatchRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreMatchRepository(
      db,
      _MockStorage(),
      _MockFunctions(),
      clock: () => testNow,
    );
  });

  test('drafts round-trip and are listed for their organizer only', () async {
    final draft = completeDraft().copyWith(
      priceAmount: 300,
      rules: 'No slides',
    );
    await repo.saveDraft(draft);

    final mine = await repo.watchDrafts('raj').firstWhere((l) => l.isNotEmpty);
    expect(mine.single.copyWith(updatedAt: null), draft);
    expect(await repo.watchDrafts('amit').first, isEmpty);
  });

  test(
    'a published match (server format) reads back with zero counters',
    () async {
      final draft = completeDraft(id: 'abc');
      await seedMatch(db, draft, testOrganizer);

      final raw = (await db.doc('matches/abc').get()).data()!;
      expect(raw['status'], 'published');
      expect(raw['currentPlayers'], 0);
      expect(raw['spotsRemaining'], 10);
      expect(raw['searchTitle'], 'saturday night football');
      expect((raw['slots'] as Map)['any'], {'needed': 7, 'filled': 0});
      expect(raw['price'], {'amount': 0, 'currency': 'NPR', 'isFree': true});

      final match = await repo.watchMatch('abc').firstWhere((m) => m != null);
      expect(match!.organizer, testOrganizer);
      expect(match.venue, testVenue);
      expect(match.startAt, draft.startAt);
      expect(match.endAt, draft.endAt);
      expect(match.slots[PositionGroup.def].needed, 2);
      expect(match.spotsRemaining, 10);
    },
  );

  test('upcoming matches: listed statuses only, soonest first', () async {
    Future<void> publishAt(String id, int day) {
      final d = completeDraft(id: id).copyWith(date: DateTime(2026, 9, day));
      return seedMatch(db, d, testOrganizer);
    }

    await publishAt('later', 30);
    await publishAt('sooner', 27);
    await publishAt('gone', 29);
    await repo.cancelMatch('gone');

    final list = await repo.watchUpcomingMatches().firstWhere(
      (l) => l.length == 2,
    );
    expect(list.map((m) => m.id), ['sooner', 'later']);
  });

  test('cancelMatch sets status', () async {
    await seedMatch(db, completeDraft(id: 'x'), testOrganizer);
    await repo.cancelMatch('x');
    final m = await repo
        .watchMatch('x')
        .firstWhere((m) => m?.status == MatchStatus.cancelled);
    expect(m!.status, MatchStatus.cancelled);
  });
}
