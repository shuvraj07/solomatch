import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/player_card.dart';
import '../../../shared/models/position_group.dart';

part 'roster_entry.freezed.dart';

/// An accepted player (Firestore `matches/{matchId}/roster/{playerId}`).
/// Written only by Cloud Functions.
@freezed
abstract class RosterEntry with _$RosterEntry {
  const factory RosterEntry({
    required PlayerCard player,
    required PositionGroup group,
    DateTime? joinedAt,
  }) = _RosterEntry;
}
