import '../../match_requests/domain/join_request.dart';
import 'football_match.dart';
import 'match_status.dart';

/// The main button on Match Details for a given viewer.
enum MatchAction {
  /// Viewer created the match.
  organizer,

  requestToJoin,

  /// Viewer's request is waiting for the organizer.
  pending,

  /// Viewer was accepted.
  playing,

  /// Organizer declined the viewer's request (final).
  declined,
  full,
  cancelled,
  started,
  completed,
}

/// Decides which action a viewer sees, from the live match and the
/// viewer's own join request (if any).
MatchAction resolveMatchAction(
  FootballMatch match,
  String viewerUid, {
  JoinRequest? myRequest,
}) {
  if (match.status == MatchStatus.cancelled) return MatchAction.cancelled;
  if (match.status == MatchStatus.completed) return MatchAction.completed;
  if (match.status == MatchStatus.started) return MatchAction.started;
  if (match.isOrganizer(viewerUid)) return MatchAction.organizer;

  switch (myRequest?.status) {
    case RequestStatus.accepted:
      return MatchAction.playing;
    case RequestStatus.pending:
      return MatchAction.pending;
    case RequestStatus.rejected:
      return MatchAction.declined;
    case RequestStatus.cancelled || null:
      break;
  }
  if (match.isFull) return MatchAction.full;
  return MatchAction.requestToJoin;
}
