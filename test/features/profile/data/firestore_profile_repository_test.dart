import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/profile/data/firestore_profile_repository.dart';
import 'package:solomatch/shared/models/availability.dart';

import '../../../fakes/test_data.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreProfileRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreProfileRepository(db, _MockStorage());
  });

  test(
    'createProfile writes profile, username claim and private doc',
    () async {
      final profile = testProfile().copyWith(
        availability: const Availability().toggle(6, TimeBand.evening),
      );
      await repo.createProfile(profile, email: 'raj@example.com');

      final player = (await db.doc('players/raj').get()).data()!;
      expect(player['username'], 'raj10');
      expect(player['primaryPosition'], 'centralMidfielder');
      expect(player['availability'], ['6.evening']);
      expect(player.containsKey('stats'), isFalse);
      expect((await db.doc('usernames/raj10').get()).data(), {'uid': 'raj'});
      expect(
        (await db.doc('users/raj').get()).data()!['email'],
        'raj@example.com',
      );
    },
  );

  test('round-trips through Firestore via watchProfile', () async {
    final profile = testProfile();
    await repo.createProfile(profile, email: null);
    final read = await repo.watchProfile('raj').firstWhere((p) => p != null);
    expect(read, profile);
  });

  test('watchProfile emits null before setup, then the profile', () async {
    final emissions = repo.watchProfile('raj').take(2).toList();
    await Future<void>.delayed(Duration.zero);
    await repo.createProfile(testProfile(), email: null);
    final values = await emissions;
    expect(values.first, isNull);
    expect(values.last?.username, 'raj10');
  });

  test('username availability and conflict', () async {
    expect(await repo.isUsernameAvailable('RAJ10'), isTrue);
    await repo.createProfile(testProfile(), email: null);
    expect(await repo.isUsernameAvailable('RAJ10'), isFalse);

    expect(
      () => repo.createProfile(testProfile(uid: 'amit'), email: null),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('updateProfile changes editable fields only', () async {
    await repo.createProfile(testProfile(), email: null);
    await repo.updateProfile(
      testProfile(username: 'hacked').copyWith(city: 'Lalitpur'),
    );
    final player = (await db.doc('players/raj').get()).data()!;
    expect(player['city'], 'Lalitpur');
    expect(player['username'], 'raj10');
  });
}
