import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/player_card.dart';
import '../../../shared/models/position_group.dart';

part 'join_request.freezed.dart';

enum RequestStatus {
  pending,
  accepted,
  rejected,

  /// Withdrawn by the player, or they left after being accepted.
  cancelled;

  static RequestStatus fromName(String name) => values.byName(name);
}

/// A player's request to join a match
/// (Firestore `matches/{matchId}/requests/{playerId}`).
@freezed
abstract class JoinRequest with _$JoinRequest {
  const factory JoinRequest({
    required String matchId,
    required PlayerCard player,
    required PositionGroup preferredGroup,
    @Default('') String message,
    required RequestStatus status,

    /// Slot the organizer placed them in, once accepted.
    PositionGroup? assignedGroup,
    DateTime? createdAt,
  }) = _JoinRequest;

  const JoinRequest._();

  String get playerId => player.uid;
}
