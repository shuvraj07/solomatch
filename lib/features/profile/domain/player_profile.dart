import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/availability.dart';
import '../../../shared/models/fitness.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/preferred_foot.dart';
import '../../../shared/models/skill_level.dart';
import 'player_stats.dart';

part 'player_profile.freezed.dart';

/// A player's public football profile (Firestore `players/{uid}`).
@freezed
abstract class PlayerProfile with _$PlayerProfile {
  const factory PlayerProfile({
    required String uid,
    required String fullName,

    /// Lowercase, unique across players (enforced via `usernames/{username}`).
    required String username,
    String? photoUrl,
    required DateTime dateOfBirth,
    required String city,
    @Default('') String bio,
    required Position primaryPosition,
    @Default(<Position>[]) List<Position> secondaryPositions,
    required SkillLevel skillLevel,
    required PreferredFoot preferredFoot,
    int? heightCm,
    @Default(0) int yearsPlaying,
    @Default(<String>[]) List<String> languages,
    @Default(Availability()) Availability availability,
    @Default(PlayerStats()) PlayerStats stats,

    /// Privacy: don't show the city to other players.
    @Default(false) bool hideCity,

    /// Set by the player. Injured players can't be picked or ask to join.
    @Default(Fitness.fit) Fitness fitness,
  }) = _PlayerProfile;
}
