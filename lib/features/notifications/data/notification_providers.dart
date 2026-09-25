import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';
import 'firebase_push_messaging.dart';
import 'firestore_notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirestoreNotificationRepository(ref.watch(firestoreProvider)),
);

final pushMessagingProvider = Provider<PushMessaging>(
  (ref) => FirebasePushMessaging(FirebaseMessaging.instance),
);

/// The signed-in user's inbox, newest first.
final inboxProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchInbox(uid);
});

final unreadCountProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(inboxProvider).value?.where((n) => !n.read).length ?? 0,
);
