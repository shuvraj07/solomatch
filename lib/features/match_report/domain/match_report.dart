import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/user_summary.dart';

part 'match_report.freezed.dart';

/// One player's contribution in a match, entered by the organizer.
@freezed
abstract class PlayerMatchLine with _$PlayerMatchLine {
  const factory PlayerMatchLine({
    @Default(0) int goals,
    @Default(0) int assists,

    /// 0–2.
    @Default(0) int yellowCards,
    @Default(false) bool redCard,
  }) = _PlayerMatchLine;

  const PlayerMatchLine._();

  static const maxGoals = 30;
  static const maxAssists = 30;
  static const maxYellowCards = 2;

  bool get isEmpty =>
      goals == 0 && assists == 0 && yellowCards == 0 && !redCard;

  /// Compact summary, e.g. "⚽2 🅰️1 🟨".
  String get summary => [
    if (goals > 0) '⚽$goals',
    if (assists > 0) '🅰️$assists',
    for (var i = 0; i < yellowCards; i++) '🟨',
    if (redCard) '🟥',
  ].join(' ');
}

/// The organizer's post-match report (stored on the match document).
@freezed
abstract class MatchReport with _$MatchReport {
  const factory MatchReport({
    @Default(<String, PlayerMatchLine>{}) Map<String, PlayerMatchLine> players,
    DateTime? submittedAt,
  }) = _MatchReport;

  const MatchReport._();

  PlayerMatchLine lineFor(String uid) =>
      players[uid] ?? const PlayerMatchLine();
}

/// Man of the Match, decided by the server when voting closes. Several
/// winners means a tie (joint award). No winners means nobody voted.
@freezed
abstract class MotmResult with _$MotmResult {
  const factory MotmResult({
    @Default(<UserSummary>[]) List<UserSummary> winners,
    @Default(0) int votes,
    @Default(0) int totalVotes,
  }) = _MotmResult;
}
