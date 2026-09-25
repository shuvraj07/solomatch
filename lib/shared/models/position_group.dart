/// The slot groups an organizer asks for when creating a match.
///
/// Stored in Firestore by [name] (`gk`, `def`, `mid`, `fwd`, `any`).
enum PositionGroup {
  gk('Goalkeeper', 'GK', '🧤'),
  def('Defender', 'DEF', '🛡️'),
  mid('Midfielder', 'MID', '⚽'),
  fwd('Forward', 'FWD', '🔥'),

  /// Flexible slots: `maxPlayers` minus the sum of the specific groups.
  any('Any position', 'ANY', '👟');

  const PositionGroup(this.label, this.shortLabel, this.emoji);

  final String label;
  final String shortLabel;
  final String emoji;

  /// Groups an organizer can request explicitly (everything except [any]).
  static const specific = [gk, def, mid, fwd];

  static PositionGroup fromName(String name) => values.byName(name);
}
