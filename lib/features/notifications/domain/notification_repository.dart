import 'app_notification.dart';

abstract interface class NotificationRepository {
  /// Newest first, live.
  Stream<List<AppNotification>> watchInbox(String uid);

  Future<void> markRead(String uid, String notificationId);

  Future<void> markAllRead(String uid, Iterable<String> notificationIds);

  /// Stores this phone's push token so the server can reach it.
  Future<void> registerDevice(String uid, String token);

  Future<void> removeDevice(String uid, String token);
}

/// Device-side push messaging (Firebase Cloud Messaging in production).
abstract interface class PushMessaging {
  /// Asks the OS for permission to show notifications. True if granted.
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  /// Pushes received while the app is open (the OS doesn't show these).
  Stream<PushMessage> get onForegroundMessage;

  /// The user tapped a notification while the app was in the background.
  Stream<PushMessage> get onOpenedApp;

  /// The notification that launched the app from terminated, if any.
  Future<PushMessage?> initialMessage();

  Future<void> deleteToken();
}
