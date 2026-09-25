import 'dart:async';

import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/join_request.dart';
import 'package:solomatch/features/match_requests/domain/match_request_repository.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/position_slots.dart';
import 'package:solomatch/features/profile/domain/player_profile.dart';
import 'package:solomatch/shared/models/position_group.dart';

import 'fake_match_repository.dart';

/// In-memory requests + roster. accept/reject/leave mimic the Cloud
/// Functions, including updating the match in [matches] so every screen
/// watching it sees the new count.
class FakeMatchRequestRepository implements MatchRequestRepository {
  FakeMatchRequestRepository(this.matches);

  final FakeMatchRepository matches;
  final _requests = <String, JoinRequest>{}; // "matchId/playerId"
  final _roster = <String, List<RosterEntry>>{};
  final _changes = StreamController<void>.broadcast();

  /// When set, the next accept fails with this (e.g. "This match is full.").
  AppFailure? acceptError;

  String _key(String matchId, String playerId) => '$matchId/$playerId';

  JoinRequest? requestOf(String matchId, String playerId) =>
      _requests[_key(matchId, playerId)];

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  void _emit() => _changes.add(null);

  @override
  Stream<JoinRequest?> watchMyRequest(String matchId, String playerId) =>
      _live(() => _requests[_key(matchId, playerId)]);

  @override
  Stream<List<JoinRequest>> watchPendingRequests(String matchId) => _live(
    () => [
      for (final r in _requests.values)
        if (r.matchId == matchId && r.status == RequestStatus.pending) r,
    ],
  );

  @override
  Stream<List<RosterEntry>> watchRoster(String matchId) =>
      _live(() => List.of(_roster[matchId] ?? const []));

  @override
  Future<void> requestToJoin({
    required FootballMatch match,
    required PlayerProfile player,
    required PositionGroup preferredGroup,
    String message = '',
  }) async {
    _requests[_key(match.id, player.uid)] = JoinRequest(
      matchId: match.id,
      player: MatchRequestMapper.cardFromProfile(player),
      preferredGroup: preferredGroup,
      message: message,
      status: RequestStatus.pending,
    );
    _emit();
  }

  @override
  Future<void> withdrawRequest(String matchId, String playerId) async {
    final key = _key(matchId, playerId);
    _requests[key] = _requests[key]!.copyWith(status: RequestStatus.cancelled);
    _emit();
  }

  @override
  Future<void> accept(
    String matchId,
    String playerId, {
    PositionGroup? group,
  }) async {
    if (acceptError case final e?) throw e;
    final key = _key(matchId, playerId);
    final request = _requests[key]!;
    final match = matches.matchOf(matchId)!;
    final slot = group ?? request.preferredGroup;
    _requests[key] = request.copyWith(
      status: RequestStatus.accepted,
      assignedGroup: slot,
    );
    (_roster[matchId] ??= []).add(
      RosterEntry(player: request.player, group: slot),
    );
    matches.push(_withCount(match, match.currentPlayers + 1, slot, 1));
    _emit();
  }

  @override
  Future<void> reject(String matchId, String playerId) async {
    final key = _key(matchId, playerId);
    _requests[key] = _requests[key]!.copyWith(status: RequestStatus.rejected);
    _emit();
  }

  @override
  Future<void> leave(String matchId) async {
    final entry = _roster[matchId]!.removeLast();
    final key = _key(matchId, entry.player.uid);
    _requests[key] = _requests[key]!.copyWith(status: RequestStatus.cancelled);
    final match = matches.matchOf(matchId)!;
    matches.push(_withCount(match, match.currentPlayers - 1, entry.group, -1));
    _emit();
  }

  static FootballMatch _withCount(
    FootballMatch m,
    int current,
    PositionGroup group,
    int delta,
  ) {
    final counts = {...m.slots.asMap};
    final c = m.slots[group];
    counts[group] = (needed: c.needed, filled: c.filled + delta);
    return m.copyWith(
      currentPlayers: current,
      slots: PositionSlots(counts),
      status: current >= m.maxPlayers
          ? MatchStatus.full
          : current == 0
          ? MatchStatus.published
          : MatchStatus.filling,
    );
  }
}
