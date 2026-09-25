import 'football_match.dart';
import 'match_status.dart';

/// The main button on Match Details for a given viewer.
enum MatchAction {
  /// Viewer created the match.
  organizer,

  requestToJoin,
  full,
  cancelled,
  started,
  completed,
}

/// Decides which action a viewer sees. Join-request states (pending,
/// accepted) are layered on top in Phase 4.
MatchAction resolveMatchAction(FootballMatch match, String viewerUid) {
  if (match.status == MatchStatus.cancelled) return MatchAction.cancelled;
  if (match.status == MatchStatus.completed) return MatchAction.completed;
  if (match.status == MatchStatus.started) return MatchAction.started;
  if (match.isOrganizer(viewerUid)) return MatchAction.organizer;
  if (match.isFull) return MatchAction.full;
  return MatchAction.requestToJoin;
}
