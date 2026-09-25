import 'dart:async';

import 'package:solomatch/features/live/data/live_repository.dart';
import 'package:solomatch/features/live/domain/live_models.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';

import 'fake_match_repository.dart';

/// In-memory [LiveRepository]. Team names are written through to [matches]
/// so the screen updates like it would from Firestore.
class FakeLiveRepository implements LiveRepository {
  FakeLiveRepository({this.matches});

  final FakeMatchRepository? matches;
  final events = <String, List<LiveEvent>>{};
  final following = <String>{}; // "matchId/uid"
  final _changes = StreamController<void>.broadcast();
  var _nextId = 0;

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<LiveEvent>> watchEvents(String matchId) =>
      _live(() => List.of(events[matchId] ?? const <LiveEvent>[]));

  @override
  Future<void> addEvent(
    String matchId,
    LiveEvent e, {
    required String by,
  }) async {
    (events[matchId] ??= []).add(
      LiveEvent(
        id: 'e${_nextId++}',
        type: e.type,
        side: e.side,
        playerUid: e.playerUid,
        playerName: e.playerName,
        minute: e.minute,
      ),
    );
    _changes.add(null);
  }

  @override
  Future<void> deleteEvent(String matchId, String eventId) async {
    events[matchId]?.removeWhere((e) => e.id == eventId);
    _changes.add(null);
  }

  @override
  Future<void> setTeams(String matchId, MatchTeams teams) async {
    final m = matches?.matchOf(matchId);
    if (m != null) matches!.push(m.copyWith(teams: teams));
  }

  @override
  Stream<bool> watchFollowing(String matchId, String uid) =>
      _live(() => following.contains('$matchId/$uid'));

  @override
  Future<void> setFollowing(
    String matchId,
    String uid, {
    required bool on,
  }) async {
    on ? following.add('$matchId/$uid') : following.remove('$matchId/$uid');
    _changes.add(null);
  }
}
