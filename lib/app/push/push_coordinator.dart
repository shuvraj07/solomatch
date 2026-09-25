import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/notifications/data/notification_providers.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../router/app_router.dart';
import '../session/session_provider.dart';
import '../session/session_state.dart';

/// App-wide key so pushes can show a snackbar from anywhere.
final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
      (ref) => GlobalKey<ScaffoldMessengerState>(),
    );

/// Wires push notifications into the app:
///  * once signed in, asks permission and registers this phone's token
///    (and keeps it up to date when FCM rotates it)
///  * pushes arriving while the app is open → snackbar with "View"
///  * tapping a notification → opens its screen (waits for sign-in if the
///    app was just launched)
class PushCoordinator extends ConsumerStatefulWidget {
  const PushCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushCoordinator> createState() => _PushCoordinatorState();
}

class _PushCoordinatorState extends ConsumerState<PushCoordinator> {
  final _subs = <StreamSubscription<Object?>>[];
  StreamSubscription<String>? _tokenRefresh;
  String? _registeredUid;
  String? _pendingRoute;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushMessagingProvider);
    _subs
      ..add(push.onForegroundMessage.listen(_showInApp))
      ..add(push.onOpenedApp.listen(_open));
    unawaited(
      push.initialMessage().then((m) {
        if (m != null) _open(m);
      }, onError: (Object e) => debugPrint('initialMessage failed: $e')),
    );
    ref.listenManual(
      sessionProvider,
      (_, next) => _onSession(next.value),
      fireImmediately: true,
    );
  }

  Future<void> _onSession(SessionState? session) async {
    if (session is! Ready) {
      _registeredUid = null;
      await _tokenRefresh?.cancel();
      _tokenRefresh = null;
      return;
    }
    _openPending();
    final uid = session.user.uid;
    if (_registeredUid == uid) return;
    _registeredUid = uid;

    final push = ref.read(pushMessagingProvider);
    final repo = ref.read(notificationRepositoryProvider);
    try {
      await push.requestPermission();
      final token = await push.getToken();
      if (token != null) await repo.registerDevice(uid, token);
      await _tokenRefresh?.cancel();
      _tokenRefresh = push.onTokenRefresh.listen(
        (t) => unawaited(repo.registerDevice(uid, t)),
      );
    } on Object catch (e) {
      // No Play Services, permission denied, offline… the in-app inbox
      // still works.
      debugPrint('Push registration failed: $e');
    }
  }

  void _open(PushMessage message) {
    final route = message.route;
    if (route == null) return;
    _pendingRoute = route;
    _openPending();
  }

  void _openPending() {
    final route = _pendingRoute;
    if (route == null || ref.read(sessionProvider).value is! Ready) return;
    _pendingRoute = null;
    unawaited(ref.read(appRouterProvider).push(route));
  }

  void _showInApp(PushMessage message) {
    final messenger = ref.read(scaffoldMessengerKeyProvider).currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message.body.isEmpty
                ? message.title
                : '${message.title}\n${message.body}',
          ),
          action: message.route == null
              ? null
              : SnackBarAction(label: 'View', onPressed: () => _open(message)),
        ),
      );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    unawaited(_tokenRefresh?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
