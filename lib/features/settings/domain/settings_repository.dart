/// Push notification categories a user can switch off. The server maps
/// every notification type to one of these (functions: categoryOf).
enum NotificationCategory {
  requests(
    'Join requests',
    'New requests, accepted or declined, players leaving',
  ),
  matches('Match updates', 'Reminders, kick-off, full, cancelled'),
  chat('Chat messages', 'Group chats and private messages'),
  reviews('Ratings & awards', 'New ratings, Man of the Match');

  const NotificationCategory(this.label, this.description);

  final String label;
  final String description;
}

/// Everything on by default; a missing entry means "on".
typedef NotificationPrefs = Map<NotificationCategory, bool>;

abstract interface class SettingsRepository {
  Stream<NotificationPrefs> watchNotificationPrefs(String uid);

  Future<void> setNotificationPref(
    String uid,
    NotificationCategory category,
    bool enabled,
  );

  /// Permanently deletes the signed-in account (server-side).
  Future<void> deleteAccount();
}
