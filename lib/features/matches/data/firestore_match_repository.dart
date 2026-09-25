import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/football_match.dart';
import '../domain/match_draft.dart';
import '../domain/match_repository.dart';
import '../domain/match_status.dart';
import 'match_mapper.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(
    this._db,
    this._storage,
    this._functions, {
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _db.collection('matches');

  CollectionReference<Map<String, dynamic>> get _drafts =>
      _db.collection('match_drafts');

  @override
  Stream<FootballMatch?> watchMatch(String matchId) =>
      _matches.doc(matchId).snapshots().map((snap) {
        final data = snap.data();
        return data == null ? null : MatchMapper.fromFirestore(snap.id, data);
      });

  @override
  Stream<List<FootballMatch>> watchUpcomingMatches({int limit = 30}) => _matches
      .where(
        'status',
        whereIn: [
          for (final s in MatchStatus.values)
            if (s.isListed) s.name,
        ],
      )
      .where('startAt', isGreaterThan: Timestamp.fromDate(_now()))
      .orderBy('startAt')
      .limit(limit)
      .snapshots()
      .map(
        (q) => [
          for (final doc in q.docs)
            MatchMapper.fromFirestore(doc.id, doc.data()),
        ],
      );

  @override
  Stream<List<FootballMatch>> watchLiveMatches({int limit = 20}) {
    final now = _now();
    // Ordered by end time, so matches that are on now come before later
    // ones; kick-off is then checked here (one range filter per query).
    return _matches
        .where(
          'status',
          whereIn: [
            for (final s in MatchStatus.values)
              if (s.isListed || s == MatchStatus.started) s.name,
          ],
        )
        .where('endAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endAt')
        .limit(limit * 3)
        .snapshots()
        .map(
          (q) => [
            for (final doc in q.docs)
              MatchMapper.fromFirestore(doc.id, doc.data()),
          ].where((m) => !m.startAt.isAfter(_now())).take(limit).toList(),
        );
  }

  @override
  Stream<List<MatchDraft>> watchDrafts(String organizerId) => _drafts
      .where('organizerId', isEqualTo: organizerId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (q) => [
          for (final doc in q.docs)
            MatchMapper.draftFromFirestore(doc.id, doc.data()),
        ],
      );

  @override
  String newMatchId() => _matches.doc().id;

  @override
  Future<void> saveDraft(MatchDraft draft) =>
      _guard(() => _drafts.doc(draft.id).set(MatchMapper.draftTo(draft)));

  @override
  Future<void> deleteDraft(String draftId) =>
      _guard(() => _drafts.doc(draftId).delete());

  @override
  Future<void> publish(MatchDraft draft) async {
    await saveDraft(draft);
    try {
      await _functions.httpsCallable('publishDraft').call<Object?>({
        'draftId': draft.id,
      });
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? const UnknownFailure().message;
      throw switch (e.code) {
        'invalid-argument' ||
        'failed-precondition' => ValidationFailure(message),
        'permission-denied' => PermissionFailure(message),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }

  @override
  Future<void> cancelMatch(String matchId) => _guard(
    () => _matches.doc(matchId).update({
      'status': MatchStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<String> uploadMatchPhoto({
    required String organizerId,
    required String matchId,
    required Uint8List bytes,
  }) async {
    try {
      final name = '${_now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref('match_photos/$organizerId/$matchId/$name');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException {
      throw const UnknownFailure("Couldn't upload the photo. Try again.");
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw switch (e.code) {
        'permission-denied' => const PermissionFailure(),
        'unavailable' => const NetworkFailure(),
        'not-found' => const NotFoundFailure(),
        _ => const UnknownFailure(),
      };
    }
  }
}
