import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/combine_latest.dart';
import '../../match_requests/domain/join_request.dart';
import '../domain/my_match_entry.dart';
import '../domain/my_matches_repository.dart';

/// Combines two live queries:
///  * `matches` where I'm the organizer
///  * collection group `requests` where I'm the player
class FirestoreMyMatchesRepository implements MyMatchesRepository {
  FirestoreMyMatchesRepository(this._db);

  final FirebaseFirestore _db;

  static const _limit = 100;

  @override
  Stream<List<MyMatchEntry>> watchMyMatches(String uid) {
    final organized = _db
        .collection('matches')
        .where('organizer.uid', isEqualTo: uid)
        .orderBy('startAt', descending: true)
        .limit(_limit)
        .snapshots()
        .map(
          (q) => [
            for (final d in q.docs)
              MyMatchEntry(
                matchId: d.id,
                role: MyMatchRole.organizer,
                title: d.data()['title'] as String,
                startAt: (d.data()['startAt'] as Timestamp).toDate(),
                venueName:
                    (d.data()['venue'] as Map<String, dynamic>?)?['name']
                        as String? ??
                    '',
              ),
          ],
        );

    final requested = _db
        .collectionGroup('requests')
        .where('player.uid', isEqualTo: uid)
        .orderBy('match.startAt', descending: true)
        .limit(_limit)
        .snapshots()
        .map(
          (q) => [
            for (final d in q.docs)
              if (d.reference.parent.parent case final match?)
                _fromRequest(match.id, d.data()),
          ],
        );

    return combineLatest2(organized, requested, (a, b) => [...a, ...b]);
  }

  static MyMatchEntry _fromRequest(String matchId, Map<String, dynamic> d) {
    final snapshot = d['match'] as Map<String, dynamic>;
    return MyMatchEntry(
      matchId: matchId,
      role: MyMatchRole.player,
      title: snapshot['title'] as String,
      startAt: (snapshot['startAt'] as Timestamp).toDate(),
      venueName: snapshot['venueName'] as String? ?? '',
      requestStatus: RequestStatus.fromName(d['status'] as String),
    );
  }
}
