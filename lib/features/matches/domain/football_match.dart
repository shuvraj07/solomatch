import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/match_format.dart';
import '../../../shared/models/price.dart';
import '../../../shared/models/skill_level.dart';
import '../../../shared/models/user_summary.dart';
import '../../../shared/models/venue.dart';
import 'match_status.dart';
import 'position_slots.dart';

part 'football_match.freezed.dart';

/// A published match (Firestore `matches/{id}`).
///
/// Named FootballMatch because `Match` is a dart:core type.
@freezed
abstract class FootballMatch with _$FootballMatch {
  const factory FootballMatch({
    required String id,
    required UserSummary organizer,
    required String title,
    required Venue venue,
    required DateTime startAt,
    required DateTime endAt,
    required MatchFormat format,
    required int maxPlayers,

    /// Accepted players. Server-maintained.
    required int currentPlayers,
    required PositionSlots slots,
    required SkillLevel skillLevel,
    required Price price,
    @Default(false) bool isIndoor,
    @Default('') String description,
    @Default('') String rules,
    @Default(<String>[]) List<String> photos,
    required MatchStatus status,
    DateTime? createdAt,
  }) = _FootballMatch;

  const FootballMatch._();

  int get spotsRemaining => (maxPlayers - currentPlayers).clamp(0, maxPlayers);

  bool get isFull => spotsRemaining == 0 || status == MatchStatus.full;

  bool isOrganizer(String uid) => organizer.uid == uid;

  Duration get duration => endAt.difference(startAt);
}
