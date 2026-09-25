import 'dart:async';

import 'package:solomatch/features/notifications/domain/app_notification.dart';
import 'package:solomatch/features/notifications/domain/notification_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository([List<AppNotification> inbox = const []])
    : _inbox = [...inbox];

  final List<AppNotification> _inbox;
  final _changes = StreamController<void>.broadcast();

  /// uid → registered push tokens.
  final devices = <String, Set<String>>{};

  List<AppNotification> get inbox => List.unmodifiable(_inbox);

  /// Simulates the server adding a notification.
  void add(AppNotification n) {
    _inbox.insert(0, n);
    _changes.add(null);
  }

  @override
  Stream<List<AppNotification>> watchInbox(String uid) async* {
    yield inbox;
    yield* _changes.stream.map((_) => inbox);
  }

  void _setRead(String id) {
    final i = _inbox.indexWhere((n) => n.id == id);
    if (i >= 0) _inbox[i] = _inbox[i].copyWith(read: true);
  }

  @override
  Future<void> markRead(String uid, String notificationId) async {
    _setRead(notificationId);
    _changes.add(null);
  }

  @override
  Future<void> markAllRead(String uid, Iterable<String> ids) async {
    ids.forEach(_setRead);
    _changes.add(null);
  }

  @override
  Future<void> registerDevice(String uid, String token) async {
    (devices[uid] ??= {}).add(token);
  }

  @override
  Future<void> removeDevice(String uid, String token) async {
    devices[uid]?.remove(token);
  }
}

class FakePushMessaging implements PushMessaging {
  FakePushMessaging({this.token = 'token-1', this.launchedFrom});

  String? token;
  PushMessage? launchedFrom;
  bool permissionRequested = false;
  bool tokenDeleted = false;

  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<PushMessage>.broadcast();
  final refresh = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async => permissionRequested = true;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => foreground.stream;

  @override
  Stream<PushMessage> get onOpenedApp => opened.stream;

  @override
  Future<PushMessage?> initialMessage() async => launchedFrom;

  @override
  Future<void> deleteToken() async {
    tokenDeleted = true;
    token = null;
  }
}
