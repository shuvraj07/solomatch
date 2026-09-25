import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/notifications/data/notification_providers.dart';

/// Signs out after unregistering this phone for push notifications.
///
/// The device token must be removed *before* signing out: afterwards the
/// app is no longer allowed to touch the user's data, and a stale token
/// would keep sending this user's notifications to a shared phone.
final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid != null) {
      try {
        final push = ref.read(pushMessagingProvider);
        final token = await push.getToken();
        if (token != null) {
          await ref
              .read(notificationRepositoryProvider)
              .removeDevice(uid, token);
        }
        await push.deleteToken();
      } on Object catch (e) {
        // Best effort: never block signing out.
        debugPrint('Could not unregister device: $e');
      }
    }
    await ref.read(authRepositoryProvider).signOut();
  };
});
