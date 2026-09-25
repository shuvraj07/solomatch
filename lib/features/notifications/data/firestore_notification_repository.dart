import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._db);

  final FirebaseFirestore _db;

  static const _inboxLimit = 50;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Stream<List<AppNotification>> watchInbox(String uid) =>
      _user(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(_inboxLimit)
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs)
                AppNotification(
                  id: d.id,
                  type: d.data()['type'] as String? ?? '',
                  title: d.data()['title'] as String? ?? '',
                  body: d.data()['body'] as String? ?? '',
                  matchId: d.data()['matchId'] as String?,
                  read: d.data()['read'] as bool? ?? false,
                  createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
                ),
            ],
          );

  @override
  Future<void> markRead(String uid, String notificationId) =>
      _user(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

  @override
  Future<void> markAllRead(String uid, Iterable<String> notificationIds) {
    final batch = _db.batch();
    for (final id in notificationIds) {
      batch.update(_user(uid).collection('notifications').doc(id), {
        'read': true,
      });
    }
    return batch.commit();
  }

  @override
  Future<void> registerDevice(String uid, String token) => _user(uid)
      .collection('devices')
      .doc(token)
      .set({'platform': 'android', 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> removeDevice(String uid, String token) =>
      _user(uid).collection('devices').doc(token).delete();
}
