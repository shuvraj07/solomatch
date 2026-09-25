import 'match_report.dart';

/// Post-match report and Man of the Match voting.
abstract interface class MatchReportRepository {
  /// Organizer only; validated and applied to career stats on the server.
  Future<void> saveReport(String matchId, Map<String, PlayerMatchLine> lines);

  /// The nominee the viewer voted for, or null.
  Stream<String?> watchMyVote(String matchId, String voterUid);

  /// Casts or changes a vote (security rules check eligibility and timing).
  Future<void> vote(String matchId, String voterUid, String nomineeUid);
}
