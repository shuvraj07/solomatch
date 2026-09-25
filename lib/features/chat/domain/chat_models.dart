import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';

enum ConversationType { group, direct }

@freezed
abstract class ChatMember with _$ChatMember {
  const factory ChatMember({required String name, String? photoUrl}) =
      _ChatMember;
}

/// A chat (Firestore `conversations/{id}`), created by Cloud Functions:
/// a match group chat, or a private organizer ↔ player chat.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required ConversationType type,
    required String matchId,

    /// The match title.
    required String title,
    required List<String> participantIds,
    @Default(<String, ChatMember>{}) Map<String, ChatMember> participants,
    String? lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,

    /// When each member last read the conversation.
    @Default(<String, DateTime>{}) Map<String, DateTime> readAt,
  }) = _Conversation;

  const Conversation._();

  bool get isGroup => type == ConversationType.group;

  /// The other person in a private chat.
  String? otherId(String me) => isGroup
      ? null
      : participantIds.firstWhere((id) => id != me, orElse: () => me);

  /// Name shown in the list and app bar.
  String displayName(String me) =>
      isGroup ? title : participants[otherId(me)]?.name ?? 'Player';

  /// New message from someone else since I last looked.
  bool isUnreadFor(String me) {
    final last = lastMessageAt;
    if (last == null || lastMessageText == null) return false;
    if (lastMessageSenderId == me) return false;
    final read = readAt[me];
    return read == null || last.isAfter(read);
  }

  /// Other members who have read up to [time] ("Seen").
  int seenBy(DateTime time, String me) => readAt.entries
      .where((e) => e.key != me && !e.value.isBefore(time))
      .length;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    String? text,
    String? imageUrl,

    /// Null while the message is still being written by the server.
    DateTime? sentAt,
  }) = _ChatMessage;
}
