import 'package:freezed_annotation/freezed_annotation.dart';

import '../../match_requests/domain/join_request.dart';

part 'my_match_entry.freezed.dart';

enum MyMatchRole { organizer, player }

/// A match the signed-in user is involved in: one they organize, or one
/// they asked to join. Titles and times come from denormalized snapshots;
/// the live status is read per match when the tile is shown.
@freezed
abstract class MyMatchEntry with _$MyMatchEntry {
  const factory MyMatchEntry({
    required String matchId,
    required MyMatchRole role,
    required String title,
    required DateTime startAt,
    @Default('') String venueName,

    /// Only for [MyMatchRole.player].
    RequestStatus? requestStatus,
  }) = _MyMatchEntry;
}

enum MyMatchesTab {
  upcoming('Upcoming'),
  requested('Requested'),
  played('Played'),
  created('Created');

  const MyMatchesTab(this.label);

  final String label;
}

/// Sorts entries into tabs. Pure, so it's easy to test.
///
/// - upcoming: organizing, or accepted, and kick-off still ahead (soonest first)
/// - requested: pending requests for matches not yet started
/// - played: organized or accepted, kick-off passed (most recent first)
/// - created: every match organized (newest kick-off first)
Map<MyMatchesTab, List<MyMatchEntry>> categorizeMyMatches(
  Iterable<MyMatchEntry> entries,
  DateTime now,
) {
  bool isIn(MyMatchEntry e) =>
      e.role == MyMatchRole.organizer ||
      e.requestStatus == RequestStatus.accepted;
  bool ahead(MyMatchEntry e) => e.startAt.isAfter(now);

  // A player could also be the organizer's own entry; keep one per match,
  // preferring the organizer view.
  final byMatch = <String, MyMatchEntry>{};
  for (final e in entries) {
    final existing = byMatch[e.matchId];
    if (existing == null || e.role == MyMatchRole.organizer) {
      byMatch[e.matchId] = e;
    }
  }
  final all = byMatch.values.toList();

  int soonest(MyMatchEntry a, MyMatchEntry b) => a.startAt.compareTo(b.startAt);
  int latest(MyMatchEntry a, MyMatchEntry b) => b.startAt.compareTo(a.startAt);

  return {
    MyMatchesTab.upcoming: all.where((e) => isIn(e) && ahead(e)).toList()
      ..sort(soonest),
    MyMatchesTab.requested:
        all
            .where((e) => e.requestStatus == RequestStatus.pending && ahead(e))
            .toList()
          ..sort(soonest),
    MyMatchesTab.played: all.where((e) => isIn(e) && !ahead(e)).toList()
      ..sort(latest),
    MyMatchesTab.created:
        all.where((e) => e.role == MyMatchRole.organizer).toList()
          ..sort(latest),
  };
}
