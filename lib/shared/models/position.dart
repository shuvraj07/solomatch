import 'position_group.dart';

/// Detailed playing positions used on player profiles.
///
/// Stored in Firestore by [name]. Each maps to exactly one [PositionGroup],
/// which is what match slots are counted in.
enum Position {
  goalkeeper('Goalkeeper', 'GK', PositionGroup.gk),
  centerBack('Center Back', 'CB', PositionGroup.def),
  fullBack('Full Back', 'FB', PositionGroup.def),
  defensiveMidfielder('Defensive Midfielder', 'CDM', PositionGroup.mid),
  centralMidfielder('Central Midfielder', 'CM', PositionGroup.mid),
  attackingMidfielder('Attacking Midfielder', 'CAM', PositionGroup.mid),
  winger('Winger', 'W', PositionGroup.fwd),
  striker('Striker', 'ST', PositionGroup.fwd);

  const Position(this.label, this.shortLabel, this.group);

  final String label;
  final String shortLabel;
  final PositionGroup group;

  static Position fromName(String name) => values.byName(name);
}
