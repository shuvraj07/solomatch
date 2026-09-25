import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/position_slots.dart';
import 'package:solomatch/shared/models/match_format.dart';
import 'package:solomatch/shared/models/position_group.dart';
import 'package:solomatch/shared/models/price.dart';
import 'package:solomatch/shared/models/skill_level.dart';
import 'package:solomatch/shared/models/user_summary.dart';
import 'package:solomatch/shared/models/venue.dart';

/// Fixed "now" for time-dependent tests: Wed 25 Sep 2026, 10:00.
final testNow = DateTime(2026, 9, 25, 10);

const testOrganizer = UserSummary(
  uid: 'raj',
  name: 'Raj Shrestha',
  username: 'raj10',
);

const testVenue = Venue(
  name: 'Dhuku Futsal',
  address: 'Baneshwor',
  city: 'Kathmandu',
);

FootballMatch testMatch({
  String id = 'm1',
  String organizerUid = 'raj',
  int currentPlayers = 0,
  int maxPlayers = 10,
  MatchStatus status = MatchStatus.published,
  PositionSlots? slots,
}) => FootballMatch(
  id: id,
  organizer: testOrganizer.copyWith(uid: organizerUid),
  title: 'Saturday Night Football',
  venue: testVenue,
  startAt: DateTime(2026, 9, 28, 18),
  endAt: DateTime(2026, 9, 28, 20),
  format: MatchFormat.fiveASide,
  maxPlayers: maxPlayers,
  currentPlayers: currentPlayers,
  slots:
      slots ??
      PositionSlots.create(
        maxPlayers: maxPlayers,
        needed: const {
          PositionGroup.gk: 1,
          PositionGroup.def: 2,
          PositionGroup.mid: 1,
          PositionGroup.fwd: 1,
        },
      ),
  skillLevel: SkillLevel.any,
  price: const Price.free(),
  status: status,
);

/// A draft with every required field filled in (valid at [testNow]).
MatchDraft completeDraft({String id = 'd1'}) => MatchDraft(
  id: id,
  organizerId: 'raj',
  title: 'Saturday Night Football',
  venue: testVenue,
  date: DateTime(2026, 9, 28),
  startMinutes: 18 * 60,
  endMinutes: 20 * 60,
  neededPositions: const {PositionGroup.gk: 1, PositionGroup.def: 2},
);
