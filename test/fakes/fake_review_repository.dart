import 'dart:async';

import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/reviews/domain/review.dart';
import 'package:solomatch/features/reviews/domain/review_repository.dart';

class FakeReviewRepository implements ReviewRepository {
  FakeReviewRepository([Iterable<Review> reviews = const []]) {
    for (final r in reviews) {
      _reviews[r.id] = r;
    }
  }

  final _reviews = <String, Review>{};
  final _changes = StreamController<void>.broadcast();

  List<Review> get all => _reviews.values.toList();

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Review>> watchReviewsFor(String uid, {int limit = 20}) => _live(
    () =>
        _reviews.values.where((r) => r.revieweeId == uid).take(limit).toList(),
  );

  @override
  Stream<Set<String>> watchRatedBy(String matchId, String reviewerId) => _live(
    () => {
      for (final r in _reviews.values)
        if (r.matchId == matchId && r.reviewerId == reviewerId) r.revieweeId,
    },
  );

  @override
  Future<void> submit(Review review) async {
    // Same as the security rule: one review per pair per match.
    if (_reviews.containsKey(review.id)) {
      throw const ValidationFailure("You've already rated this player.");
    }
    _reviews[review.id] = review;
    _changes.add(null);
  }
}
