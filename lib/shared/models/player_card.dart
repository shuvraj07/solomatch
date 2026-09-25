import 'package:freezed_annotation/freezed_annotation.dart';

import 'position.dart';
import 'skill_level.dart';

part 'player_card.freezed.dart';

/// Football summary of a player, copied into join requests and roster
/// entries so organizers can decide without opening each profile.
/// Security rules check it matches the player's real profile.
@freezed
abstract class PlayerCard with _$PlayerCard {
  const factory PlayerCard({
    required String uid,
    required String name,
    required String username,
    String? photoUrl,
    required Position primaryPosition,
    @Default(<Position>[]) List<Position> secondaryPositions,
    required SkillLevel skillLevel,
    @Default(0) double ratingAvg,
    @Default(0) int ratingCount,
    @Default(0) int gamesPlayed,
  }) = _PlayerCard;
}
