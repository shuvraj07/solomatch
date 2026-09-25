import '../../../shared/models/position_group.dart';
import '../../matches/domain/football_match.dart';
import '../../profile/domain/player_profile.dart';
import 'join_request.dart';
import 'roster_entry.dart';

/// Join requests and the roster. Creating/withdrawing a request are client
/// writes checked by security rules; accept, reject and leave go through
/// Cloud Functions, which enforce capacity in a transaction.
abstract interface class MatchRequestRepository {
  /// The viewer's own request for a match (null if they never asked).
  Stream<JoinRequest?> watchMyRequest(String matchId, String playerId);

  /// Pending requests, oldest first. Organizer only.
  Stream<List<JoinRequest>> watchPendingRequests(String matchId);

  Stream<List<RosterEntry>> watchRoster(String matchId);

  Future<void> requestToJoin({
    required FootballMatch match,
    required PlayerProfile player,
    required PositionGroup preferredGroup,
    String message,
  });

  Future<void> withdrawRequest(String matchId, String playerId);

  /// [group] overrides the player's preferred slot.
  Future<void> accept(String matchId, String playerId, {PositionGroup? group});

  Future<void> reject(String matchId, String playerId);

  Future<void> leave(String matchId);
}
