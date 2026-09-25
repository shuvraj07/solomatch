import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/app_failure.dart';
import '../../../shared/models/position_group.dart';
import '../../matches/domain/football_match.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/join_request.dart';
import '../domain/match_request_repository.dart';
import '../domain/roster_entry.dart';
import 'match_request_mapper.dart';

class FirestoreMatchRequestRepository implements MatchRequestRepository {
  FirestoreMatchRequestRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _match(String id) =>
      _db.collection('matches').doc(id);

  @override
  Stream<JoinRequest?> watchMyRequest(String matchId, String playerId) =>
      _match(matchId)
          .collection('requests')
          .doc(playerId)
          .snapshots()
          .map((snap) {
            final data = snap.data();
            return data == null
                ? null
                : MatchRequestMapper.requestFrom(matchId, data);
          });

  @override
  Stream<List<JoinRequest>> watchPendingRequests(String matchId) =>
      _match(matchId)
          .collection('requests')
          .where('status', isEqualTo: RequestStatus.pending.name)
          .orderBy('createdAt')
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs)
                MatchRequestMapper.requestFrom(matchId, d.data()),
            ],
          );

  @override
  Stream<List<RosterEntry>> watchRoster(String matchId) => _match(matchId)
      .collection('roster')
      .orderBy('joinedAt')
      .snapshots()
      .map(
        (q) => [
          for (final d in q.docs) MatchRequestMapper.rosterFrom(d.data()),
        ],
      );

  @override
  Future<void> requestToJoin({
    required FootballMatch match,
    required PlayerProfile player,
    required PositionGroup preferredGroup,
    String message = '',
  }) => _write(
    () => _match(match.id)
        .collection('requests')
        .doc(player.uid)
        .set(
          MatchRequestMapper.newRequest(
            match: match,
            player: player,
            preferredGroup: preferredGroup,
            message: message,
          ),
        ),
  );

  @override
  Future<void> withdrawRequest(String matchId, String playerId) => _write(
    () => _match(matchId).collection('requests').doc(playerId).update({
      'status': RequestStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> accept(
    String matchId,
    String playerId, {
    PositionGroup? group,
  }) => _call('acceptJoinRequest', {
    'matchId': matchId,
    'playerId': playerId,
    'group': ?group?.name,
  });

  @override
  Future<void> reject(String matchId, String playerId) =>
      _call('rejectJoinRequest', {'matchId': matchId, 'playerId': playerId});

  @override
  Future<void> leave(String matchId) =>
      _call('leaveJoinedMatch', {'matchId': matchId});

  Future<void> _write(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw switch (e.code) {
        // Rules reject requests to full/cancelled/started matches too.
        'permission-denied' => const ValidationFailure(
          "You can't join this match right now.",
        ),
        'unavailable' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      await _functions.httpsCallable(name).call<Object?>(data);
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? const UnknownFailure().message;
      throw switch (e.code) {
        'failed-precondition' ||
        'invalid-argument' => ValidationFailure(message),
        'permission-denied' => PermissionFailure(message),
        'not-found' => NotFoundFailure(message),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }
}
