/// Lifecycle of a published match. Drafts live in their own collection and
/// never have a status.
///
/// ```
/// published ──(first player)──▶ filling ──(capacity)──▶ full
///      └──────────────┬──────────────┘                   │
///                     ▼                                  ▼
///                  started ─────────────▶ completed
/// any state before started ──▶ cancelled
/// ```
/// After publishing, only `cancelled` is set by the organizer's app; every
/// other transition is made on the server.
enum MatchStatus {
  published('Open'),
  filling('Filling up'),
  full('Full'),
  started('In progress'),
  completed('Played'),
  cancelled('Cancelled');

  const MatchStatus(this.label);

  final String label;

  /// Players can still ask to join.
  bool get acceptsRequests => this == published || this == filling;

  /// Shown in discovery lists.
  bool get isListed => acceptsRequests || this == full;

  bool get isOver => this == completed || this == cancelled;

  static MatchStatus fromName(String name) => values.byName(name);
}
