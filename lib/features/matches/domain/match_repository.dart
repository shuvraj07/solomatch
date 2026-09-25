import 'dart:typed_data';

import '../../../shared/models/user_summary.dart';
import 'football_match.dart';
import 'match_draft.dart';

abstract interface class MatchRepository {
  /// Live match; emits null if it doesn't exist (or was removed).
  Stream<FootballMatch?> watchMatch(String matchId);

  /// Live list of open/full matches that haven't started, soonest first.
  /// (Phase 3 replaces this with location-aware discovery.)
  Stream<List<FootballMatch>> watchUpcomingMatches({int limit = 30});

  Stream<List<MatchDraft>> watchDrafts(String organizerId);

  /// A fresh ID shared by a draft and the match it becomes.
  String newMatchId();

  Future<void> saveDraft(MatchDraft draft);

  Future<void> deleteDraft(String draftId);

  /// Creates `matches/{draft.id}` and deletes the draft atomically.
  /// Callers must validate the draft first (see MatchValidator).
  Future<void> publish(MatchDraft draft, UserSummary organizer);

  /// Organizer-only; security rules reject anyone else.
  Future<void> cancelMatch(String matchId);

  Future<String> uploadMatchPhoto({
    required String organizerId,
    required String matchId,
    required Uint8List bytes,
  });
}
