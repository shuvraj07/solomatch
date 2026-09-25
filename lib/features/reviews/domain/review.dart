import 'package:freezed_annotation/freezed_annotation.dart';

import '../../match_requests/domain/roster_entry.dart';
import '../../matches/domain/football_match.dart';
import '../../matches/domain/match_status.dart';

part 'review.freezed.dart';

/// A 1–5 star rating one participant gave another after a match
/// (Firestore `reviews/{matchId}_{reviewerId}_{revieweeId}`).
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String matchId,
    required String reviewerId,
    required String revieweeId,

    /// 1–5.
    required int rating,
    @Default('') String comment,
    required String reviewerName,
    String? reviewerPhotoUrl,
    required String matchTitle,
    DateTime? createdAt,
  }) = _Review;

  const Review._();

  String get id => reviewId(matchId, reviewerId, revieweeId);
}

String reviewId(String matchId, String reviewerId, String revieweeId) =>
    '${matchId}_${reviewerId}_$revieweeId';

/// Rules shared by the UI; firestore.rules enforces the same on the server.
abstract final class ReviewRules {
  static const window = Duration(days: 7);
  static const maxComment = 300;

  /// Organizer + everyone on the roster.
  static Set<String> participants(FootballMatch m, List<RosterEntry> roster) =>
      {m.organizer.uid, for (final e in roster) e.player.uid};

  static bool isOpen(FootballMatch m, DateTime now) =>
      m.status == MatchStatus.completed && now.isBefore(m.endAt.add(window));

  /// People [me] can still rate for this match.
  static List<String> toRate(
    FootballMatch m,
    List<RosterEntry> roster,
    String me,
    Set<String> alreadyRated,
  ) {
    final all = participants(m, roster);
    if (!all.contains(me)) return const [];
    return [
      for (final uid in all)
        if (uid != me && !alreadyRated.contains(uid)) uid,
    ];
  }
}
