import 'dart:async';

import 'package:solomatch/features/match_report/domain/match_report.dart';
import 'package:solomatch/features/match_report/domain/match_report_repository.dart';

import 'fake_match_repository.dart';

/// In-memory report + votes. Saving a report writes it onto the match in
/// [matches], like the Cloud Function does, so match screens update.
class FakeMatchReportRepository implements MatchReportRepository {
  FakeMatchReportRepository(this.matches);

  final FakeMatchRepository matches;
  final votes = <String, String>{}; // "matchId/voter" -> nominee
  final savedReports = <String, Map<String, PlayerMatchLine>>{};
  final _changes = StreamController<void>.broadcast();

  @override
  Future<void> saveReport(
    String matchId,
    Map<String, PlayerMatchLine> lines,
  ) async {
    savedReports[matchId] = lines;
    final m = matches.matchOf(matchId)!;
    matches.push(m.copyWith(report: MatchReport(players: lines)));
  }

  @override
  Stream<String?> watchMyVote(String matchId, String voterUid) async* {
    String? read() => votes['$matchId/$voterUid'];
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Future<void> vote(String matchId, String voterUid, String nomineeUid) async {
    votes['$matchId/$voterUid'] = nomineeUid;
    _changes.add(null);
  }
}
