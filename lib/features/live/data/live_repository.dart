import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../matches/domain/football_match.dart';
import '../domain/live_models.dart';

/// Live events, team names and following a match.
abstract interface class LiveRepository {
  Stream<List<LiveEvent>> watchEvents(String matchId);

  Future<void> addEvent(String matchId, LiveEvent event, {required String by});

  /// Undo.
  Future<void> deleteEvent(String matchId, String eventId);

  Future<void> setTeams(String matchId, MatchTeams teams);

  /// Moves the organizer's clock to [phase]. [elapsedSeconds] is the time
  /// played so far (kept while paused; the base for a running period).
  Future<void> setClock(
    String matchId,
    ClockPhase phase, {
    required int elapsedSeconds,
  });

  Stream<bool> watchFollowing(String matchId, String uid);

  Future<void> setFollowing(String matchId, String uid, {required bool on});
}

class FirestoreLiveRepository implements LiveRepository {
  FirestoreLiveRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _match(String id) =>
      _db.collection('matches').doc(id);

  @override
  Stream<List<LiveEvent>> watchEvents(String matchId) =>
      _match(matchId)
          .collection('events')
          .orderBy('createdAt')
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs)
                LiveEvent(
                  id: d.id,
                  type: LiveEventType.values.byName(d['type'] as String),
                  side: TeamSide.values.byName(d['team'] as String),
                  playerUid: d.data()['playerUid'] as String?,
                  playerName: d.data()['playerName'] as String? ?? '',
                  minute: (d.data()['minute'] as num?)?.toInt() ?? 0,
                  createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
                ),
            ],
          );

  @override
  Future<void> addEvent(String matchId, LiveEvent e, {required String by}) =>
      _guard(
        () => _match(matchId).collection('events').add({
          'type': e.type.name,
          'team': e.side.name,
          'playerUid': e.playerUid,
          'playerName': e.playerName.trim(),
          'minute': e.minute,
          'by': by,
          'createdAt': FieldValue.serverTimestamp(),
        }),
      );

  @override
  Future<void> deleteEvent(String matchId, String eventId) =>
      _guard(() => _match(matchId).collection('events').doc(eventId).delete());

  @override
  Future<void> setTeams(String matchId, MatchTeams teams) => _guard(
    () => _match(matchId).update({
      'teams': {'home': teams.home.trim(), 'away': teams.away.trim()},
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> setClock(
    String matchId,
    ClockPhase phase, {
    required int elapsedSeconds,
  }) => _guard(
    () => _match(matchId).update({
      'clock': {
        'phase': phase.wireName,
        'periodStartedAt': phase.running ? FieldValue.serverTimestamp() : null,
        'elapsedBefore': elapsedSeconds,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Stream<bool> watchFollowing(String matchId, String uid) =>
      _match(matchId)
          .collection('followers')
          .doc(uid)
          .snapshots()
          .map((s) => s.exists);

  @override
  Future<void> setFollowing(String matchId, String uid, {required bool on}) {
    final ref = _match(matchId).collection('followers').doc(uid);
    return _guard(
      () => on
          ? ref.set({'createdAt': FieldValue.serverTimestamp()})
          : ref.delete(),
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw switch (e.code) {
        'permission-denied' => const PermissionFailure(
          'Live updates are open from 10 minutes before kick-off '
          'until 3 hours after the final whistle.',
        ),
        'unavailable' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }
}

final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => FirestoreLiveRepository(ref.watch(firestoreProvider)),
);

final liveEventsProvider = StreamProvider.autoDispose
    .family<List<LiveEvent>, String>(
      (ref, matchId) => ref.watch(liveRepositoryProvider).watchEvents(matchId),
    );

typedef FollowKey = ({String matchId, String uid});

final isFollowingProvider = StreamProvider.autoDispose.family<bool, FollowKey>(
  (ref, k) =>
      ref.watch(liveRepositoryProvider).watchFollowing(k.matchId, k.uid),
);
