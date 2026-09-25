import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/safety_repository.dart';
import 'firestore_safety_repository.dart';

final safetyRepositoryProvider = Provider<SafetyRepository>(
  (ref) => FirestoreSafetyRepository(ref.watch(firestoreProvider)),
);

final blockedPlayersProvider = StreamProvider.autoDispose<List<BlockedPlayer>>((
  ref,
) {
  final uid = ref.watch(currentProfileProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(safetyRepositoryProvider).watchBlocked(uid);
});

/// UIDs I've blocked (for hiding their messages, showing Unblock).
final blockedIdsProvider = Provider.autoDispose<Set<String>>(
  (ref) => {
    for (final b
        in ref.watch(blockedPlayersProvider).value ?? const <BlockedPlayer>[])
      b.uid,
  },
);
