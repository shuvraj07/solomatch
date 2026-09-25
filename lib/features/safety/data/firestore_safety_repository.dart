import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/safety_repository.dart';

class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _blocks(String uid) =>
      _db.collection('users').doc(uid).collection('blocks');

  @override
  Stream<List<BlockedPlayer>> watchBlocked(String uid) => _blocks(uid)
      .snapshots()
      .map(
        (q) => [
          for (final d in q.docs)
            (uid: d.id, name: d.data()['name'] as String? ?? 'Player'),
        ],
      );

  @override
  Future<void> block(String uid, BlockedPlayer player) =>
      _blocks(uid).doc(player.uid).set({
        'name': player.name.length > 60
            ? player.name.substring(0, 60)
            : player.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> unblock(String uid, String blockedUid) =>
      _blocks(uid).doc(blockedUid).delete();

  @override
  Future<void> report({
    required String reporterId,
    required ReportTarget type,
    required String targetId,
    required String targetName,
    required ReportReason reason,
    String details = '',
  }) => _db.collection('reports').add({
    'reporterId': reporterId,
    'targetType': type.name,
    'targetId': targetId,
    'targetName': targetName.length > 120
        ? targetName.substring(0, 120)
        : targetName,
    'reason': reason.wireName,
    'details': details.trim(),
    'status': 'open',
    'createdAt': FieldValue.serverTimestamp(),
  });
}
