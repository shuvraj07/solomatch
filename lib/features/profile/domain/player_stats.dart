import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_stats.freezed.dart';

/// Server-maintained counters. Clients can read these but never write them
/// (enforced by firestore.rules).
@freezed
abstract class PlayerStats with _$PlayerStats {
  const factory PlayerStats({
    @Default(0) int gamesPlayed,
    @Default(0) int gamesOrganized,
    @Default(0) double ratingAvg,
    @Default(0) int ratingCount,
  }) = _PlayerStats;

  const PlayerStats._();

  bool get hasRating => ratingCount > 0;
}
