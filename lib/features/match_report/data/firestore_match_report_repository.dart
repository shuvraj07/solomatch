import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/app_failure.dart';
import '../../matches/data/match_mapper.dart';
import '../domain/match_report.dart';
import '../domain/match_report_repository.dart';

class FirestoreMatchReportRepository implements MatchReportRepository {
  FirestoreMatchReportRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _vote(String matchId, String uid) =>
      _db.collection('matches').doc(matchId).collection('motm_votes').doc(uid);

  @override
  Future<void> saveReport(
    String matchId,
    Map<String, PlayerMatchLine> lines,
  ) async {
    try {
      await _functions.httpsCallable('saveMatchReport').call<Object?>({
        'matchId': matchId,
        'players': {
          for (final e in lines.entries) e.key: MatchMapper.lineTo(e.value),
        },
      });
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? const UnknownFailure().message;
      throw switch (e.code) {
        'failed-precondition' ||
        'invalid-argument' => ValidationFailure(message),
        'permission-denied' => PermissionFailure(message),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }

  @override
  Stream<String?> watchMyVote(String matchId, String voterUid) => _vote(
    matchId,
    voterUid,
  ).snapshots().map((s) => s.data()?['nomineeId'] as String?);

  @override
  Future<void> vote(String matchId, String voterUid, String nomineeUid) async {
    try {
      await _vote(
        matchId,
        voterUid,
      ).set({'nomineeId': nomineeUid, 'votedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw switch (e.code) {
        'permission-denied' => const ValidationFailure(
          'Voting is closed for this match.',
        ),
        'unavailable' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }
}
