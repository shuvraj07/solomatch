import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/chat_models.dart';
import '../domain/chat_repository.dart';
import 'firestore_chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => FirestoreChatRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
    ref.watch(functionsProvider),
  ),
);

final conversationsProvider = StreamProvider.autoDispose<List<Conversation>>((
  ref,
) {
  final uid = ref.watch(currentProfileProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchConversations(uid);
});

final conversationProvider = StreamProvider.autoDispose
    .family<Conversation?, String>(
      (ref, id) => ref.watch(chatRepositoryProvider).watchConversation(id),
    );

final messagesProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>(
      (ref, id) => ref.watch(chatRepositoryProvider).watchMessages(id),
    );

/// Conversations with something new, for the Messages tab badge.
final unreadChatsProvider = Provider.autoDispose<int>((ref) {
  final uid = ref.watch(currentProfileProvider)?.uid;
  if (uid == null) return 0;
  final list = ref.watch(conversationsProvider).value ?? const [];
  return list.where((c) => c.isUnreadFor(uid)).length;
});
