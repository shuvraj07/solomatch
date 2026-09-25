import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/review.dart';
import '../domain/review_repository.dart';
import 'firestore_review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirestoreReviewRepository(ref.watch(firestoreProvider)),
);

final reviewsForPlayerProvider = StreamProvider.autoDispose
    .family<List<Review>, String>(
      (ref, uid) => ref.watch(reviewRepositoryProvider).watchReviewsFor(uid),
    );

/// Who I've already rated in a match.
final ratedByMeProvider = StreamProvider.autoDispose
    .family<Set<String>, String>((ref, matchId) {
      final uid = ref.watch(currentProfileProvider)?.uid;
      if (uid == null) return Stream.value(const {});
      return ref.watch(reviewRepositoryProvider).watchRatedBy(matchId, uid);
    });
