import 'dart:async';
import 'dart:typed_data';

import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/chat/domain/chat_models.dart';
import 'package:solomatch/features/chat/domain/chat_repository.dart';

/// In-memory chat. Sending updates the conversation preview like the
/// server trigger does; [receive] simulates someone else writing.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository([Iterable<Conversation> conversations = const []]) {
    for (final c in conversations) {
      _conversations[c.id] = c;
    }
  }

  final _conversations = <String, Conversation>{};
  final _messages = <String, List<ChatMessage>>{};
  final _changes = StreamController<void>.broadcast();
  var _clock = DateTime(2026, 9, 25, 18);
  var _nextId = 0;

  /// Who is allowed to open a private chat for a match (matchId → uids).
  final directAllowed = <String, Set<String>>{};

  Conversation? conversation(String id) => _conversations[id];
  List<ChatMessage> messagesOf(String id) => _messages[id] ?? const [];

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  DateTime _tick() => _clock = _clock.add(const Duration(minutes: 1));

  void _post(String conversationId, ChatMessage m) {
    (_messages[conversationId] ??= []).add(m);
    final c = _conversations[conversationId]!;
    _conversations[conversationId] = c.copyWith(
      lastMessageText: m.imageUrl != null ? '📷 Photo' : m.text,
      lastMessageSenderId: m.senderId,
      lastMessageAt: m.sentAt,
    );
    _changes.add(null);
  }

  /// Another member sends a message.
  void receive(String conversationId, String senderId, String text) => _post(
    conversationId,
    ChatMessage(
      id: 'm${_nextId++}',
      senderId: senderId,
      text: text,
      sentAt: _tick(),
    ),
  );

  /// Another member reads the chat now.
  void readBy(String conversationId, String uid) {
    final c = _conversations[conversationId]!;
    _conversations[conversationId] = c.copyWith(
      readAt: {...c.readAt, uid: _tick()},
    );
    _changes.add(null);
  }

  @override
  Stream<List<Conversation>> watchConversations(String uid) => _live(
    () =>
        _conversations.values
            .where((c) => c.participantIds.contains(uid))
            .toList()
          ..sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
              a.lastMessageAt ?? DateTime(0),
            ),
          ),
  );

  @override
  Stream<Conversation?> watchConversation(String conversationId) =>
      _live(() => _conversations[conversationId]);

  @override
  Stream<List<ChatMessage>> watchMessages(
    String conversationId, {
    int limit = 100,
  }) => _live(() => List.of(messagesOf(conversationId)));

  @override
  Future<void> sendText(
    String conversationId,
    String senderId,
    String text,
  ) async {
    if (text.trim().isEmpty) return;
    _post(
      conversationId,
      ChatMessage(
        id: 'm${_nextId++}',
        senderId: senderId,
        text: text.trim(),
        sentAt: _tick(),
      ),
    );
  }

  @override
  Future<void> sendImage(
    String conversationId,
    String senderId,
    Uint8List bytes,
  ) async => _post(
    conversationId,
    ChatMessage(
      id: 'm${_nextId++}',
      senderId: senderId,
      imageUrl: 'https://example.com/photo.jpg',
      sentAt: _tick(),
    ),
  );

  @override
  Future<void> markRead(String conversationId, String uid) async =>
      readBy(conversationId, uid);

  @override
  Future<String> openDirectChat({
    required String matchId,
    required String playerId,
  }) async {
    if (!(directAllowed[matchId]?.contains(playerId) ?? false)) {
      throw const ValidationFailure(
        'Ask to join the match first, then you can message the organizer.',
      );
    }
    final id = 'dm_${matchId}_$playerId';
    _conversations[id] ??= Conversation(
      id: id,
      type: ConversationType.direct,
      matchId: matchId,
      title: 'Saturday Night Football',
      participantIds: ['raj', playerId],
      participants: {
        'raj': const ChatMember(name: 'Raj Shrestha'),
        playerId: ChatMember(name: playerId),
      },
    );
    _changes.add(null);
    return id;
  }
}
