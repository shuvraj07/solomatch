import 'review.dart';

abstract interface class ReviewRepository {
  /// Reviews a player received, newest first. Live.
  Stream<List<Review>> watchReviewsFor(String uid, {int limit = 20});

  /// Who [reviewerId] has already rated in this match. Live.
  Stream<Set<String>> watchRatedBy(String matchId, String reviewerId);

  /// Creates the review; the server updates the player's average.
  Future<void> submit(Review review);
}
