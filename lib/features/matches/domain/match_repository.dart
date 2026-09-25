import 'dart:typed_data';

import 'football_match.dart';
import 'match_draft.dart';

abstract interface class MatchRepository {
  /// Live match; emits null if it doesn't exist (or was removed).
  Stream<FootballMatch?> watchMatch(String matchId);

  /// Live list of open/full matches that haven't started, soonest first.
  /// (Phase 3 replaces this with location-aware discovery.)
  Stream<List<FootballMatch>> watchUpcomingMatches({int limit = 30});

  /// Matches being played right now: kicked off and not yet ended. Includes
  /// matches past kick-off that the server hasn't marked started yet.
  Stream<List<FootballMatch>> watchLiveMatches({int limit = 20});

  Stream<List<MatchDraft>> watchDrafts(String organizerId);

  /// A fresh ID shared by a draft and the match it becomes.
  String newMatchId();

  Future<void> saveDraft(MatchDraft draft);

  Future<void> deleteDraft(String draftId);

  /// Saves the draft, then publishes it on the server, which re-validates
  /// it, puts confirmed players on the roster and deletes the draft.
  /// Callers should validate first for quick feedback (MatchValidator).
  Future<void> publish(MatchDraft draft);

  /// Organizer-only; security rules reject anyone else.
  Future<void> cancelMatch(String matchId);

  Future<String> uploadMatchPhoto({
    required String organizerId,
    required String matchId,
    required Uint8List bytes,
  });
}
