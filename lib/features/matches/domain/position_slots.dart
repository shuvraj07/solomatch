import '../../../shared/models/position_group.dart';

/// Needed vs. filled for one position group.
typedef SlotCount = ({int needed, int filled});

/// How many players a match wants per position group.
///
/// Organizers set GK/DEF/MID/FWD; [PositionGroup.any] is always the
/// remainder up to `maxPlayers`, so the groups add up to the roster size.
class PositionSlots {
  const PositionSlots(this._counts);

  /// Builds slots for a new match (nothing filled yet).
  factory PositionSlots.create({
    required int maxPlayers,
    required Map<PositionGroup, int> needed,
  }) {
    final specific = {
      for (final g in PositionGroup.specific) g: needed[g] ?? 0,
    };
    final used = specific.values.fold(0, (a, b) => a + b);
    return PositionSlots({
      for (final e in specific.entries) e.key: (needed: e.value, filled: 0),
      PositionGroup.any: (needed: maxPlayers - used, filled: 0),
    });
  }

  final Map<PositionGroup, SlotCount> _counts;

  SlotCount operator [](PositionGroup group) =>
      _counts[group] ?? (needed: 0, filled: 0);

  int get totalNeeded =>
      PositionGroup.values.fold(0, (sum, g) => sum + this[g].needed);

  int get totalFilled =>
      PositionGroup.values.fold(0, (sum, g) => sum + this[g].filled);

  int openIn(PositionGroup group) {
    final c = this[group];
    return (c.needed - c.filled).clamp(0, c.needed);
  }

  /// Groups that still have open places, e.g. for "Need: 🧤 1 GK" badges.
  Map<PositionGroup, int> get openByGroup => {
    for (final g in PositionGroup.values)
      if (openIn(g) > 0) g: openIn(g),
  };

  Map<PositionGroup, SlotCount> get asMap => Map.unmodifiable(_counts);

  @override
  bool operator ==(Object other) =>
      other is PositionSlots &&
      PositionGroup.values.every((g) => other[g] == this[g]);

  @override
  int get hashCode => Object.hashAll(PositionGroup.values.map((g) => this[g]));
}
