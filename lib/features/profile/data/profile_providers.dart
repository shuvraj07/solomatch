import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../domain/player_profile.dart';
import '../domain/profile_repository.dart';
import 'firestore_profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirestoreProfileRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  ),
);

/// Live profile of any player.
final playerProfileProvider = StreamProvider.family<PlayerProfile?, String>(
  (ref, uid) => ref.watch(profileRepositoryProvider).watchProfile(uid),
);
