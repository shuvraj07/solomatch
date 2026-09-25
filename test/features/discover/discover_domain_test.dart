import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/features/discover/domain/match_filters.dart';
import 'package:solomatch/features/discover/domain/matching_service.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/position_slots.dart';
import 'package:solomatch/shared/models/availability.dart';
import 'package:solomatch/shared/models/match_format.dart';
import 'package:solomatch/shared/models/position.dart';
import 'package:solomatch/shared/models/position_group.dart';
import 'package:solomatch/shared/models/price.dart';
import 'package:solomatch/shared/models/skill_level.dart';

import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';

void main() {
  // testNow is Friday 25 Sep 2026, 10:00; testMatch is Monday 28, 18:00.
  final monday = testMatch();
  final saturday = testMatch(id: 'sat').copyWith(
    startAt: DateTime(2026, 9, 26, 8),
    endAt: DateTime(2026, 9, 26, 9),
  );
  final today = testMatch(id: 'today').copyWith(
    startAt: DateTime(2026, 9, 25, 19),
    endAt: DateTime(2026, 9, 25, 20),
  );

  group('DateFilter', () {
    test('today, tomorrow, weekend, next 7 days', () {
      bool on(DateFilter f, DateTime t) => f.includes(t, testNow);
      expect(on(DateFilter.today, today.startAt), isTrue);
      expect(on(DateFilter.today, saturday.startAt), isFalse);
      expect(on(DateFilter.tomorrow, saturday.startAt), isTrue);
      expect(on(DateFilter.weekend, saturday.startAt), isTrue);
      expect(on(DateFilter.weekend, monday.startAt), isFalse);
      expect(on(DateFilter.thisWeek, monday.startAt), isTrue);
      expect(on(DateFilter.thisWeek, DateTime(2026, 10, 2, 18)), isFalse);
    });
  });

  group('MatchFilters.accepts', () {
    bool ok(MatchFilters f, [FootballMatch? m]) =>
        f.accepts(m ?? monday, testNow);

    test('search matches title, venue and area, every word', () {
      expect(ok(const MatchFilters(query: 'saturday')), isTrue);
      expect(ok(const MatchFilters(query: 'dhuku baneshwor')), isTrue);
      expect(ok(const MatchFilters(query: 'KATHMANDU')), isTrue);
      expect(ok(const MatchFilters(query: 'dhuku lalitpur')), isFalse);
    });

    test('format, level, price, indoor', () {
      expect(
        ok(const MatchFilters(formats: {MatchFormat.sevenASide})),
        isFalse,
      );
      expect(ok(const MatchFilters(formats: {MatchFormat.fiveASide})), isTrue);

      final advanced = monday.copyWith(skillLevel: SkillLevel.advanced);
      const wantsBeginner = MatchFilters(skill: SkillLevel.beginner);
      expect(ok(wantsBeginner, advanced), isFalse);
      // "Any level" matches are shown for every level.
      expect(ok(wantsBeginner), isTrue);

      final paid = monday.copyWith(price: const Price(amount: 200));
      expect(ok(const MatchFilters(freeOnly: true), paid), isFalse);
      expect(ok(const MatchFilters(indoor: true)), isFalse);
      expect(ok(const MatchFilters(indoor: false)), isTrue);
    });

    test('position needs an open place in that group or "any"', () {
      final noGk = monday.copyWith(
        slots: PositionSlots.create(
          maxPlayers: 10,
          needed: const {PositionGroup.def: 5, PositionGroup.fwd: 5},
        ),
      );
      expect(ok(const MatchFilters(position: PositionGroup.gk), noGk), isFalse);
      expect(ok(const MatchFilters(position: PositionGroup.def), noGk), isTrue);
    });

    test('full matches are hidden unless asked for', () {
      final full = testMatch(currentPlayers: 10, status: MatchStatus.full);
      expect(ok(const MatchFilters(), full), isFalse);
      expect(ok(const MatchFilters(hideFull: false), full), isTrue);
    });

    test('activeCount and reset', () {
      const f = MatchFilters(
        query: 'x',
        freeOnly: true,
        skill: SkillLevel.beginner,
      );
      expect(f.activeCount, 2);
      expect(f.reset().activeCount, 0);
      expect(f.reset().query, 'x');
    });
  });

  group('MatchingService', () {
    // Raj: CM (MID), secondary CAM, intermediate, Kathmandu.
    final raj = testProfile().copyWith(
      availability: const Availability({
        (weekday: DateTime.monday, band: TimeBand.evening),
      }),
    );

    test('scores position, level, schedule, city and soonness', () {
      final fit = MatchingService.score(raj, monday, testNow);
      // MID open 30 + any level 15 + Monday evening 20 + Kathmandu 15.
      // (Kick-off is more than 3 days away.)
      expect(fit.score, 80);
      expect(fit.reasons, [
        'Needs a MID',
        'All levels',
        'Fits your schedule',
        'In Kathmandu',
      ]);
    });

    test('a level mismatch and another city score lower', () {
      final far = monday.copyWith(
        skillLevel: SkillLevel.advanced,
        venue: testVenue.copyWith(city: 'Pokhara'),
        startAt: DateTime(2026, 10, 1, 7),
      );
      final fit = MatchingService.score(raj, far, testNow);
      // MID 30 + one level apart 10.
      expect(fit.score, 40);
      expect(fit.reasons, ['Needs a MID']);
    });

    test('rank puts unjoinable matches last', () {
      final mine = testMatch(id: 'mine', organizerUid: 'raj');
      final other = testMatch(id: 'other', organizerUid: 'sita');
      final ranked = MatchingService.rank(raj, [mine, other], testNow);
      expect(ranked.map((r) => r.match.id), ['other', 'mine']);
      expect(ranked.last.fit.score, -1);
    });

    test('secondary position scores when the main one is taken', () {
      final midOnly = monday.copyWith(
        slots: PositionSlots.create(
          maxPlayers: 1,
          needed: const {PositionGroup.mid: 1},
        ),
      );
      final keeper = raj.copyWith(
        primaryPosition: Position.goalkeeper,
        secondaryPositions: const [Position.centralMidfielder],
      );
      final fit = MatchingService.score(keeper, midOnly, testNow);
      expect(fit.reasons.first, 'Needs a MID');
      expect(fit.score, 65); // 15 + 15 + 20 + 15
    });
  });
}
