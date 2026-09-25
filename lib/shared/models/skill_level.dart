/// Player skill, and the level a match is aimed at.
///
/// [any] is only meaningful on matches ("all levels welcome").
enum SkillLevel {
  beginner('Beginner', 0),
  intermediate('Intermediate', 1),
  advanced('Advanced', 2),
  any('Any level', -1);

  const SkillLevel(this.label, this.rank);

  final String label;

  /// Ordering used for "how far apart" comparisons; -1 for [any].
  final int rank;

  /// Levels a player can choose for their own profile.
  static const playerLevels = [beginner, intermediate, advanced];

  /// Number of levels between two skills, or 0 if either is [any].
  int distanceTo(SkillLevel other) {
    if (this == any || other == any) return 0;
    return (rank - other.rank).abs();
  }

  static SkillLevel fromName(String name) => values.byName(name);
}
