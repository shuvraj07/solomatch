import '../../match_report/domain/match_report.dart';
import '../../matches/domain/football_match.dart';
import '../../matches/domain/match_status.dart';

enum TeamSide {
  home,
  away;

  String nameIn(MatchTeams t) => this == home ? t.home : t.away;
}

enum LiveEventType {
  goal('⚽', 'Goal'),
  yellow('🟨', 'Yellow card'),
  red('🟥', 'Red card');

  const LiveEventType(this.emoji, this.label);

  final String emoji;
  final String label;
}

/// A goal or card posted by the organizer during the match
/// (`matches/{id}/events/{eventId}`).
class LiveEvent {
  const LiveEvent({
    this.id = '',
    required this.type,
    required this.side,
    this.playerUid,
    this.playerName = '',
    required this.minute,
    this.createdAt,
  });

  final String id;
  final LiveEventType type;
  final TeamSide side;

  /// Null for a guest or an unknown scorer.
  final String? playerUid;
  final String playerName;
  final int minute;
  final DateTime? createdAt;
}

/// Where a match is on its clock.
enum LivePhase { upcoming, live, fullTime, cancelled }

/// Pure match-clock and score logic, unit-tested.
abstract final class LiveMatch {
  /// Organizers can post from shortly before kick-off until a while after
  /// the final whistle (matches firestore.rules).
  static const earlyWindow = Duration(minutes: 10);
  static const lateWindow = Duration(hours: 3);

  static LivePhase phase(FootballMatch m, DateTime now) {
    if (m.status == MatchStatus.cancelled) return LivePhase.cancelled;
    if (m.status == MatchStatus.completed || !now.isBefore(m.endAt)) {
      return LivePhase.fullTime;
    }
    if (m.status == MatchStatus.started || !now.isBefore(m.startAt)) {
      return LivePhase.live;
    }
    return LivePhase.upcoming;
  }

  /// Football-style minute: 1' in the first minute, capped at the length.
  static int minute(FootballMatch m, DateTime now) {
    final elapsed = now.difference(m.startAt).inMinutes + 1;
    return elapsed.clamp(0, m.duration.inMinutes);
  }

  static bool canPost(FootballMatch m, String uid, DateTime now) =>
      m.isOrganizer(uid) &&
      m.status != MatchStatus.cancelled &&
      !now.isBefore(m.startAt.subtract(earlyWindow)) &&
      !now.isAfter(m.endAt.add(lateWindow));

  /// Score counted from the events (instant on the match page; the
  /// server-kept `match.score` is used in lists).
  static LiveScore scoreOf(Iterable<LiveEvent> events) {
    var home = 0;
    var away = 0;
    for (final e in events) {
      if (e.type != LiveEventType.goal) continue;
      e.side == TeamSide.home ? home++ : away++;
    }
    return (home: home, away: away);
  }

  /// "Tigers 2 – 1 Eagles".
  static String scoreLine(MatchTeams t, LiveScore s) =>
      '${t.home} ${s.home} – ${s.away} ${t.away}';

  /// Goals and cards per player, to prefill the post-match report.
  static Map<String, PlayerMatchLine> reportLines(Iterable<LiveEvent> events) {
    final lines = <String, PlayerMatchLine>{};
    for (final e in events) {
      final uid = e.playerUid;
      if (uid == null) continue;
      final l = lines[uid] ?? const PlayerMatchLine();
      lines[uid] = switch (e.type) {
        LiveEventType.goal => l.copyWith(
          goals: (l.goals + 1).clamp(0, PlayerMatchLine.maxGoals),
        ),
        LiveEventType.yellow => l.copyWith(
          yellowCards: (l.yellowCards + 1).clamp(0, 2),
        ),
        LiveEventType.red => l.copyWith(redCard: true),
      };
    }
    return lines;
  }
}
