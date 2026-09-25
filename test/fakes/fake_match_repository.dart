import 'dart:async';
import 'dart:typed_data';

import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_repository.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/shared/models/price.dart';
import 'package:solomatch/shared/models/user_summary.dart';

/// In-memory [MatchRepository]. Call [push] to simulate a Firestore change
/// arriving from another device.
class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({Iterable<FootballMatch> matches = const []}) {
    for (final m in matches) {
      _matches[m.id] = m;
    }
  }

  final _matches = <String, FootballMatch>{};
  final drafts = <String, MatchDraft>{};
  final _changes = StreamController<void>.broadcast();
  final uploads = <String>[];
  var _nextId = 0;

  FootballMatch? matchOf(String id) => _matches[id];

  void push(FootballMatch match) {
    _matches[match.id] = match;
    _changes.add(null);
  }

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<FootballMatch?> watchMatch(String matchId) =>
      _live(() => _matches[matchId]);

  @override
  Stream<List<FootballMatch>> watchUpcomingMatches({int limit = 30}) => _live(
    () =>
        _matches.values.where((m) => m.status.isListed).toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt)),
  );

  @override
  Stream<List<MatchDraft>> watchDrafts(String organizerId) => _live(
    () => drafts.values.where((d) => d.organizerId == organizerId).toList(),
  );

  @override
  String newMatchId() => 'match${_nextId++}';

  @override
  Future<void> saveDraft(MatchDraft draft) async {
    drafts[draft.id] = draft;
    _changes.add(null);
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    drafts.remove(draftId);
    _changes.add(null);
  }

  @override
  Future<void> publish(MatchDraft draft) async {
    drafts.remove(draft.id);
    final confirmed = draft.confirmedCount;
    push(
      FootballMatch(
        id: draft.id,
        // The real server reads the organizer's profile; tests use the uid.
        organizer: UserSummary(
          uid: draft.organizerId,
          name: draft.organizerId,
          username: draft.organizerId,
        ),
        title: draft.title.trim(),
        venue: draft.venue!,
        startAt: draft.startAt!,
        endAt: draft.endAt!,
        format: draft.format,
        maxPlayers: draft.maxPlayers,
        currentPlayers: confirmed,
        guestCount: draft.guestCount,
        slots: draft.slots,
        skillLevel: draft.skillLevel,
        price: Price(amount: draft.priceAmount),
        isIndoor: draft.isIndoor,
        description: draft.description,
        rules: draft.rules,
        photos: draft.photos,
        status: confirmed >= draft.maxPlayers
            ? MatchStatus.full
            : confirmed > 0
            ? MatchStatus.filling
            : MatchStatus.published,
      ),
    );
  }

  @override
  Future<void> cancelMatch(String matchId) async {
    push(_matches[matchId]!.copyWith(status: MatchStatus.cancelled));
  }

  @override
  Future<String> uploadMatchPhoto({
    required String organizerId,
    required String matchId,
    required Uint8List bytes,
  }) async {
    uploads.add(matchId);
    return 'https://example.com/$matchId/${uploads.length}.jpg';
  }
}
