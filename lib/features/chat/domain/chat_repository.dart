import 'dart:typed_data';

import 'chat_models.dart';

abstract interface class ChatRepository {
  /// My conversations, most recent activity first. Live.
  Stream<List<Conversation>> watchConversations(String uid);

  Stream<Conversation?> watchConversation(String conversationId);

  /// Newest [limit] messages, oldest first. Live.
  Stream<List<ChatMessage>> watchMessages(
    String conversationId, {
    int limit = 100,
  });

  Future<void> sendText(String conversationId, String senderId, String text);

  Future<void> sendImage(
    String conversationId,
    String senderId,
    Uint8List bytes,
  );

  /// Moves my read marker to now.
  Future<void> markRead(String conversationId, String uid);

  /// Opens (creating if needed) the organizer ↔ player chat for a match.
  /// Returns the conversation ID.
  Future<String> openDirectChat({
    required String matchId,
    required String playerId,
  });
}

/// The group chat ID for a match (created by the server once someone is on
/// the roster).
String groupChatId(String matchId) => 'match_$matchId';
