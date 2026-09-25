import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_stats.freezed.dart';

/// Server-maintained career totals. Clients can read these but never write
/// them (enforced by firestore.rules); Cloud Functions update them when a
/// match completes, a report is saved or Man of the Match is decided.
@freezed
abstract class PlayerStats with _$PlayerStats {
  const factory PlayerStats({
    @Default(0) int gamesPlayed,
    @Default(0) int gamesOrganized,
    @Default(0) double ratingAvg,
    @Default(0) int ratingCount,
    @Default(0) int goals,
    @Default(0) int assists,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int motmAwards,
  }) = _PlayerStats;

  const PlayerStats._();

  bool get hasRating => ratingCount > 0;
}
