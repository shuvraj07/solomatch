typedef BlockedPlayer = ({String uid, String name});

enum ReportReason {
  harassment('Harassment or abuse'),
  noShow("Didn't show up"),
  unsafe('Unsafe or violent play'),
  fake('Fake profile or match'),
  spam('Spam or scam'),
  inappropriate('Inappropriate content'),
  other('Something else');

  const ReportReason(this.label);

  final String label;

  /// Value stored in Firestore (matches firestore.rules).
  String get wireName => switch (this) {
    ReportReason.noShow => 'no_show',
    _ => name,
  };
}

enum ReportTarget { player, match }

/// Blocking and reporting. Blocks: the blocked player can't request to
/// join your matches, and neither of you can message the other; their
/// messages are hidden from you in group chats.
abstract interface class SafetyRepository {
  Stream<List<BlockedPlayer>> watchBlocked(String uid);

  Future<void> block(String uid, BlockedPlayer player);

  Future<void> unblock(String uid, String blockedUid);

  Future<void> report({
    required String reporterId,
    required ReportTarget type,
    required String targetId,
    required String targetName,
    required ReportReason reason,
    String details,
  });
}
