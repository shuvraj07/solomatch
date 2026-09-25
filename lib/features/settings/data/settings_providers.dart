import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/settings_repository.dart';
import 'firestore_settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => FirestoreSettingsRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  ),
);

final notificationPrefsProvider = StreamProvider.autoDispose<NotificationPrefs>(
  (ref) {
    final uid = ref.watch(currentProfileProvider)?.uid;
    if (uid == null) return const Stream.empty();
    return ref.watch(settingsRepositoryProvider).watchNotificationPrefs(uid);
  },
);
