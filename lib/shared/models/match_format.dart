/// Match size, stored in Firestore by [name] (`fiveASide`, ...).
enum MatchFormat {
  fiveASide(5),
  sevenASide(7),
  nineASide(9),
  elevenASide(11);

  const MatchFormat(this.playersPerSide);

  final int playersPerSide;

  String get label => '${playersPerSide}v$playersPerSide';

  /// Suggested roster size for both teams; organizers can override it.
  int get defaultMaxPlayers => playersPerSide * 2;

  static MatchFormat fromName(String name) => values.byName(name);
}
