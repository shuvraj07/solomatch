import 'package:firebase_messaging/firebase_messaging.dart';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

/// Firebase Cloud Messaging behind [PushMessaging].
class FirebasePushMessaging implements PushMessaging {
  FirebasePushMessaging(this._fcm);

  final FirebaseMessaging _fcm;

  static PushMessage _toPush(RemoteMessage m) => (
    title: m.notification?.title ?? '',
    body: m.notification?.body ?? '',
    route: m.data['route'] as String?,
  );

  @override
  Future<bool> requestPermission() async {
    // On Android 13+ this shows the system "Allow notifications?" prompt.
    final settings = await _fcm.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => _fcm.getToken();

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Stream<PushMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage.map(_toPush);

  @override
  Stream<PushMessage> get onOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toPush);

  @override
  Future<PushMessage?> initialMessage() async {
    final m = await _fcm.getInitialMessage();
    return m == null ? null : _toPush(m);
  }

  @override
  Future<void> deleteToken() => _fcm.deleteToken();
}
