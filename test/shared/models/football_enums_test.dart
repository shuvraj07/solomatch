import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/shared/models/match_format.dart';
import 'package:solomatch/shared/models/position.dart';
import 'package:solomatch/shared/models/position_group.dart';
import 'package:solomatch/shared/models/skill_level.dart';

void main() {
  group('Position', () {
    test('every detailed position maps to a specific group', () {
      for (final position in Position.values) {
        expect(PositionGroup.specific, contains(position.group));
      }
    });

    test('groups positions as documented', () {
      expect(Position.goalkeeper.group, PositionGroup.gk);
      expect(Position.centerBack.group, PositionGroup.def);
      expect(Position.fullBack.group, PositionGroup.def);
      expect(Position.attackingMidfielder.group, PositionGroup.mid);
      expect(Position.winger.group, PositionGroup.fwd);
      expect(Position.striker.group, PositionGroup.fwd);
    });

    test('round-trips through its stored name', () {
      for (final position in Position.values) {
        expect(Position.fromName(position.name), position);
      }
    });
  });

  group('SkillLevel.distanceTo', () {
    test('is 0 when either side is any', () {
      expect(SkillLevel.any.distanceTo(SkillLevel.advanced), 0);
      expect(SkillLevel.beginner.distanceTo(SkillLevel.any), 0);
    });

    test('counts levels apart symmetrically', () {
      expect(SkillLevel.beginner.distanceTo(SkillLevel.advanced), 2);
      expect(SkillLevel.advanced.distanceTo(SkillLevel.beginner), 2);
      expect(SkillLevel.intermediate.distanceTo(SkillLevel.intermediate), 0);
    });
  });

  group('MatchFormat', () {
    test('labels and default roster size', () {
      expect(MatchFormat.fiveASide.label, '5v5');
      expect(MatchFormat.fiveASide.defaultMaxPlayers, 10);
      expect(MatchFormat.elevenASide.defaultMaxPlayers, 22);
    });
  });
}
