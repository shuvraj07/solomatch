import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/match_format.dart';
import '../../../shared/models/price.dart';
import '../../../shared/models/skill_level.dart';
import '../../../shared/models/user_summary.dart';
import '../../../shared/models/venue.dart';
import '../../match_report/domain/match_report.dart';
import 'match_status.dart';
import 'position_slots.dart';

part 'football_match.freezed.dart';

/// State of a venue booking made with the match.
enum BookingStatus {
  confirmed,

  /// The organizer cancelled the match; the slot was given back.
  released,

  /// The venue cancelled; the organizer needs another venue.
  cancelledByVenue;

  static BookingStatus fromWire(String s) => switch (s) {
    'cancelled_by_venue' => cancelledByVenue,
    'released' => released,
    _ => confirmed,
  };
}

/// Team names shown in the live match center.
typedef MatchTeams = ({String home, String away});

/// Live score, kept by the server from the organizer's goal events.
typedef LiveScore = ({int home, int away});

/// The venue slot booked for a match (`matches/{id}.booking`).
typedef MatchBooking = ({
  String venueId,
  String slotId,
  BookingStatus status,
  String reason,
});

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

    /// Confirmed friends without a SoloMatch account (counted in
    /// [currentPlayers], not on the roster).
    @Default(0) int guestCount,
    required PositionSlots slots,
    required SkillLevel skillLevel,
    required Price price,
    @Default(false) bool isIndoor,
    @Default('') String description,
    @Default('') String rules,
    @Default(<String>[]) List<String> photos,
    required MatchStatus status,
    DateTime? createdAt,

    /// Set when the match completes: end + 24 h. The report can be
    /// edited and MOTM votes cast until then.
    DateTime? votingClosesAt,
    MatchReport? report,

    /// Null until voting closes.
    MotmResult? motm,

    /// Set when the organizer booked a venue slot through the app.
    MatchBooking? booking,

    /// Live match center: team names, score and how many people follow.
    @Default((home: 'Team A', away: 'Team B')) MatchTeams teams,
    LiveScore? score,
    @Default(0) int followerCount,
  }) = _FootballMatch;

  const FootballMatch._();

  int get spotsRemaining => (maxPlayers - currentPlayers).clamp(0, maxPlayers);

  bool get isFull => spotsRemaining == 0 || status == MatchStatus.full;

  bool isOrganizer(String uid) => organizer.uid == uid;

  Duration get duration => endAt.difference(startAt);

  /// The post-match window (report edits, MOTM votes) is open.
  bool isPostMatchOpen(DateTime now) =>
      status == MatchStatus.completed &&
      motm == null &&
      (votingClosesAt?.isAfter(now) ?? false);
}
