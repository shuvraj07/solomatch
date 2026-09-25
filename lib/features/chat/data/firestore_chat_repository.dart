import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/chat_models.dart';
import '../domain/chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._db, this._storage, this._functions);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  static Conversation _conversation(String id, Map<String, dynamic> d) {
    final last = d['lastMessage'] as Map<String, dynamic>?;
    return Conversation(
      id: id,
      type: d['type'] == 'group'
          ? ConversationType.group
          : ConversationType.direct,
      matchId: d['matchId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      participantIds: [
        for (final p in d['participantIds'] as List<Object?>? ?? const [])
          p! as String,
      ],
      participants: {
        for (final e
            in (d['participants'] as Map<String, dynamic>? ?? {}).entries)
          e.key: ChatMember(
            name: (e.value as Map<String, dynamic>)['name'] as String? ?? '',
            photoUrl: (e.value as Map<String, dynamic>)['photoUrl'] as String?,
          ),
      },
      lastMessageText: last?['text'] as String?,
      lastMessageSenderId: last?['senderId'] as String?,
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      readAt: {
        for (final e in (d['readAt'] as Map<String, dynamic>? ?? {}).entries)
          if (e.value case final Timestamp t) e.key: t.toDate(),
      },
    );
  }

  @override
  Stream<List<Conversation>> watchConversations(String uid) => _conversations
      .where('participantIds', arrayContains: uid)
      .orderBy('lastMessageAt', descending: true)
      .limit(100)
      .snapshots()
      .map((q) => [for (final d in q.docs) _conversation(d.id, d.data())]);

  @override
  Stream<Conversation?> watchConversation(String conversationId) =>
      _conversations.doc(conversationId).snapshots().map((s) {
        final data = s.data();
        return data == null ? null : _conversation(s.id, data);
      });

  @override
  Stream<List<ChatMessage>> watchMessages(
    String conversationId, {
    int limit = 100,
  }) => _conversations
      .doc(conversationId)
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(limit)
      .snapshots(includeMetadataChanges: true)
      .map(
        (q) => [
          for (final d in q.docs.reversed)
            ChatMessage(
              id: d.id,
              senderId: d.data()['senderId'] as String,
              text: d.data()['text'] as String?,
              imageUrl: d.data()['imageUrl'] as String?,
              // Pending local writes have no server time yet.
              sentAt: (d.data()['sentAt'] as Timestamp?)?.toDate(),
            ),
        ],
      );

  Future<void> _add(String conversationId, Map<String, Object?> data) async {
    try {
      await _conversations.doc(conversationId).collection('messages').add({
        ...data,
        'sentAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw e.code == 'permission-denied'
          ? const PermissionFailure("You can't post in this chat.")
          : const NetworkFailure();
    }
  }

  @override
  Future<void> sendText(String conversationId, String senderId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _add(conversationId, {
      'senderId': senderId,
      'text': trimmed.length > 2000 ? trimmed.substring(0, 2000) : trimmed,
    });
  }

  @override
  Future<void> sendImage(
    String conversationId,
    String senderId,
    Uint8List bytes,
  ) async {
    final String url;
    try {
      final ref = _storage.ref(
        'chat_images/$senderId/$conversationId/'
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      url = await ref.getDownloadURL();
    } on FirebaseException {
      throw const UnknownFailure("Couldn't send the photo. Try again.");
    }
    await _add(conversationId, {'senderId': senderId, 'imageUrl': url});
  }

  @override
  Future<void> markRead(String conversationId, String uid) => _conversations
      .doc(conversationId)
      .update({'readAt.$uid': FieldValue.serverTimestamp()});

  @override
  Future<String> openDirectChat({
    required String matchId,
    required String playerId,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('openDirectConversation')
          .call<Map<String, dynamic>>({
            'matchId': matchId,
            'playerId': playerId,
          });
      return result.data['conversationId'] as String;
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? const UnknownFailure().message;
      throw switch (e.code) {
        'failed-precondition' ||
        'invalid-argument' => ValidationFailure(message),
        'permission-denied' => PermissionFailure(message),
        _ => const NetworkFailure(),
      };
    }
  }
}
