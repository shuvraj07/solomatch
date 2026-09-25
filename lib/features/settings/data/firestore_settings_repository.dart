import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/settings_repository.dart';

class FirestoreSettingsRepository implements SettingsRepository {
  FirestoreSettingsRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  @override
  Stream<NotificationPrefs> watchNotificationPrefs(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((s) {
        final raw =
            s.data()?['notificationPrefs'] as Map<String, dynamic>? ?? const {};
        return {
          for (final c in NotificationCategory.values)
            c: raw[c.name] as bool? ?? true,
        };
      });

  @override
  Future<void> setNotificationPref(
    String uid,
    NotificationCategory category,
    bool enabled,
  ) => _db.collection('users').doc(uid).set({
    'notificationPrefs': {category.name: enabled},
  }, SetOptions(merge: true));

  @override
  Future<void> deleteAccount() async {
    try {
      await _functions
          .httpsCallable(
            'deleteMyAccount',
            options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
          )
          .call<Object?>();
    } on FirebaseFunctionsException {
      throw const UnknownFailure(
        "Couldn't delete your account. Check your connection and try again.",
      );
    }
  }
}
