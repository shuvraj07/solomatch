import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/match_format.dart';
import '../../../shared/models/position_group.dart';
import '../../../shared/models/skill_level.dart';
import '../../../shared/models/venue.dart';
import 'lineup_player.dart';
import 'position_slots.dart';

part 'match_draft.freezed.dart';

/// A match being created (Firestore `match_drafts/{id}`). Fields are
/// optional until the organizer fills them in; the same [id] becomes the
/// published match's ID.
@freezed
abstract class MatchDraft with _$MatchDraft {
  const factory MatchDraft({
    required String id,
    required String organizerId,
    @Default('') String title,
    Venue? venue,

    /// Calendar day of the match (time part ignored).
    DateTime? date,

    /// Minutes after midnight, e.g. 18:00 → 1080.
    int? startMinutes,
    int? endMinutes,
    @Default(MatchFormat.fiveASide) MatchFormat format,
    @Default(10) int maxPlayers,
    @Default(<PositionGroup, int>{}) Map<PositionGroup, int> neededPositions,
    @Default(SkillLevel.any) SkillLevel skillLevel,

    /// Per-player fee in NPR; 0 = free.
    @Default(0) int priceAmount,
    @Default(false) bool isIndoor,
    @Default('') String description,
    @Default('') String rules,
    @Default(<String>[]) List<String> photos,

    /// The organizer takes a roster spot too.
    @Default(false) bool organizerPlaying,
    PositionGroup? organizerGroup,

    /// SoloMatch users already confirmed (friends who are coming).
    @Default(<LineupPlayer>[]) List<LineupPlayer> lineup,

    /// Confirmed friends who aren't on SoloMatch.
    @Default(0) int guestCount,
    DateTime? updatedAt,
  }) = _MatchDraft;

  const MatchDraft._();

  DateTime? get startAt => _at(startMinutes);

  /// An end time at or before the start means the match runs past midnight.
  DateTime? get endAt {
    final start = startAt;
    final end = _at(endMinutes);
    if (start == null || end == null) return null;
    return end.isAfter(start) ? end : end.add(const Duration(days: 1));
  }

  int get specificPositionsTotal => PositionGroup.specific.fold(
    0,
    (sum, g) => sum + (neededPositions[g] ?? 0),
  );

  /// Players already confirmed before posting.
  int get confirmedCount =>
      lineup.length + guestCount + (organizerPlaying ? 1 : 0);

  /// Places still open for requests once published.
  int get openSpots => maxPlayers - confirmedCount;

  PositionSlots get slots =>
      PositionSlots.create(maxPlayers: maxPlayers, needed: neededPositions);

  DateTime? _at(int? minutes) {
    final day = date;
    if (day == null || minutes == null) return null;
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }
}
