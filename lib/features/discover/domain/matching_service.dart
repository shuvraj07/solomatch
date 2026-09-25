import '../../../shared/models/position_group.dart';
import '../../../shared/models/skill_level.dart';
import '../../matches/domain/football_match.dart';
import '../../profile/domain/player_profile.dart';

/// How well a match suits a player, with the reasons shown on the card.
typedef MatchScore = ({int score, List<String> reasons});

/// A match with its score for the current player.
typedef RankedMatch = ({FootballMatch match, MatchScore fit});

/// Ranks matches for a player. Pure and deterministic, so it's unit-tested
/// directly and can move to the server later without changes.
///
/// Points (max 100):
/// - Position: an open place for your main position 30, secondary 15,
///   only "any position" places 10.
/// - Skill: the match's level is yours 25 (or "any level" 15), one level
///   apart 10, two apart 0.
/// - Your availability covers kick-off: 20.
/// - Same city: 15.
/// - Kick-off within 3 days: 10.
abstract final class MatchingService {
  /// Matches at or above this score are "Recommended for you".
  static const recommendedThreshold = 50;

  static MatchScore score(
    PlayerProfile player,
    FootballMatch match,
    DateTime now,
  ) {
    var score = 0;
    final reasons = <String>[];
    final slots = match.slots;

    final main = player.primaryPosition.group;
    final secondary = {for (final p in player.secondaryPositions) p.group}
      ..remove(main);
    if (slots.openIn(main) > 0) {
      score += 30;
      reasons.add('Needs a ${main.shortLabel}');
    } else if (secondary.any((g) => slots.openIn(g) > 0)) {
      final g = secondary.firstWhere((g) => slots.openIn(g) > 0);
      score += 15;
      reasons.add('Needs a ${g.shortLabel}');
    } else if (slots.openIn(PositionGroup.any) > 0) {
      score += 10;
    }

    if (match.skillLevel == SkillLevel.any) {
      score += 15;
      reasons.add('All levels');
    } else {
      switch (match.skillLevel.distanceTo(player.skillLevel)) {
        case 0:
          score += 25;
          reasons.add('Your level');
        case 1:
          score += 10;
      }
    }

    if (player.availability.covers(match.startAt)) {
      score += 20;
      reasons.add('Fits your schedule');
    }

    if (match.venue.city.trim().toLowerCase() ==
        player.city.trim().toLowerCase()) {
      score += 15;
      reasons.add('In ${match.venue.city}');
    }

    final untilKickOff = match.startAt.difference(now);
    if (!untilKickOff.isNegative && untilKickOff <= const Duration(days: 3)) {
      score += 10;
    }

    return (score: score, reasons: reasons);
  }

  /// Whether [player] could join [match] at all.
  static bool isJoinable(PlayerProfile player, FootballMatch match) =>
      match.status.acceptsRequests &&
      !match.isFull &&
      !match.isOrganizer(player.uid);

  /// Scores [matches] and orders them best first (ties: sooner first).
  /// Matches the player can't join score -1 and go last.
  static List<RankedMatch> rank(
    PlayerProfile player,
    Iterable<FootballMatch> matches,
    DateTime now,
  ) {
    final ranked = [
      for (final m in matches)
        (
          match: m,
          fit: isJoinable(player, m)
              ? score(player, m, now)
              : (score: -1, reasons: const <String>[]),
        ),
    ];
    ranked.sort((a, b) {
      final byScore = b.fit.score.compareTo(a.fit.score);
      return byScore != 0
          ? byScore
          : a.match.startAt.compareTo(b.match.startAt);
    });
    return ranked;
  }
}
