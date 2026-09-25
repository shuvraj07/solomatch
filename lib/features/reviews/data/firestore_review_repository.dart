import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/review.dart';
import '../domain/review_repository.dart';

class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  static Review _from(Map<String, dynamic> d) {
    final reviewer = d['reviewer'] as Map<String, dynamic>? ?? const {};
    return Review(
      matchId: d['matchId'] as String,
      reviewerId: d['reviewerId'] as String,
      revieweeId: d['revieweeId'] as String,
      rating: (d['rating'] as num).toInt(),
      comment: d['comment'] as String? ?? '',
      reviewerName: reviewer['name'] as String? ?? 'Player',
      reviewerPhotoUrl: reviewer['photoUrl'] as String?,
      matchTitle: d['matchTitle'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<Review>> watchReviewsFor(String uid, {int limit = 20}) => _reviews
      .where('revieweeId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((q) => [for (final d in q.docs) _from(d.data())]);

  @override
  Stream<Set<String>> watchRatedBy(String matchId, String reviewerId) =>
      _reviews
          .where('matchId', isEqualTo: matchId)
          .where('reviewerId', isEqualTo: reviewerId)
          .snapshots()
          .map(
            (q) => {for (final d in q.docs) d.data()['revieweeId'] as String},
          );

  @override
  Future<void> submit(Review review) async {
    try {
      await _reviews.doc(review.id).set({
        'matchId': review.matchId,
        'reviewerId': review.reviewerId,
        'revieweeId': review.revieweeId,
        'rating': review.rating,
        'comment': review.comment.trim(),
        'reviewer': {
          'name': review.reviewerName,
          'photoUrl': review.reviewerPhotoUrl,
        },
        'matchTitle': review.matchTitle,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.code == 'permission-denied'
          ? const ValidationFailure(
              "You can't rate this player (already rated, or the 7-day "
              'window has closed).',
            )
          : const NetworkFailure();
    }
  }
}
