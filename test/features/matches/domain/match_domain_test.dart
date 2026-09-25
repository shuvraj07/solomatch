import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/features/matches/domain/match_action.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/position_slots.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../../fakes/match_test_data.dart';

void main() {
  group('PositionSlots', () {
    test('ANY is the remainder so groups add up to maxPlayers', () {
      final slots = PositionSlots.create(
        maxPlayers: 10,
        needed: const {PositionGroup.gk: 1, PositionGroup.def: 2},
      );
      expect(slots[PositionGroup.any].needed, 7);
      expect(slots.totalNeeded, 10);
      expect(slots.totalFilled, 0);
    });

    test('openByGroup lists only groups with open places', () {
      const slots = PositionSlots({
        PositionGroup.gk: (needed: 1, filled: 1),
        PositionGroup.def: (needed: 2, filled: 1),
        PositionGroup.any: (needed: 3, filled: 0),
      });
      expect(slots.openByGroup, {PositionGroup.def: 1, PositionGroup.any: 3});
    });
  });

  group('MatchDraft times', () {
    test('combines date and minutes', () {
      final d = completeDraft();
      expect(d.startAt, DateTime(2026, 9, 28, 18));
      expect(d.endAt, DateTime(2026, 9, 28, 20));
    });

    test('an end time before the start rolls to the next day', () {
      final d = completeDraft().copyWith(startMinutes: 22 * 60, endMinutes: 30);
      expect(d.endAt, DateTime(2026, 9, 29, 0, 30));
    });

    test('times are null until date and time are set', () {
      const d = MatchDraft(id: 'x', organizerId: 'raj');
      expect(d.startAt, isNull);
      expect(d.endAt, isNull);
    });
  });

  group('resolveMatchAction', () {
    test('visitor sees Request to Join on an open match', () {
      expect(
        resolveMatchAction(testMatch(), 'amit'),
        MatchAction.requestToJoin,
      );
    });

    test('organizer sees the organizer action', () {
      expect(resolveMatchAction(testMatch(), 'raj'), MatchAction.organizer);
    });

    test('full match shows Match Full', () {
      expect(
        resolveMatchAction(testMatch(currentPlayers: 10), 'amit'),
        MatchAction.full,
      );
    });

    test('cancelled, started and completed override everything', () {
      expect(
        resolveMatchAction(testMatch(status: MatchStatus.cancelled), 'raj'),
        MatchAction.cancelled,
      );
      expect(
        resolveMatchAction(testMatch(status: MatchStatus.started), 'amit'),
        MatchAction.started,
      );
      expect(
        resolveMatchAction(testMatch(status: MatchStatus.completed), 'amit'),
        MatchAction.completed,
      );
    });
  });
}
