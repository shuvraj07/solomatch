/// How fit a player says they are. Set by the player on their profile.
/// Injured players can't be picked for a match or ask to join one.
enum Fitness {
  fit('Fully fit', '✅'),
  doubtful('Minor knock', '🤕'),
  injured('Injured', '🚑');

  const Fitness(this.label, this.emoji);

  final String label;
  final String emoji;

  bool get canPlay => this != injured;

  static Fitness fromName(String? name) =>
      values.asNameMap()[name] ?? Fitness.fit;
}
