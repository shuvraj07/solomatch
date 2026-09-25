import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/my_match_entry.dart';
import '../domain/my_matches_repository.dart';
import 'firestore_my_matches_repository.dart';

final myMatchesRepositoryProvider = Provider<MyMatchesRepository>(
  (ref) => FirestoreMyMatchesRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's matches, split into tabs.
final myMatchesProvider =
    StreamProvider.autoDispose<Map<MyMatchesTab, List<MyMatchEntry>>>((ref) {
      final uid = ref.watch(currentProfileProvider)?.uid;
      if (uid == null) return const Stream.empty();
      return ref
          .watch(myMatchesRepositoryProvider)
          .watchMyMatches(uid)
          .map((list) => categorizeMyMatches(list, DateTime.now()));
    });
