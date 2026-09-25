import '../../../core/constants/app_constants.dart';
import 'create_match_step.dart';
import 'match_draft.dart';

/// Business rules for creating a match. Keep in sync with the `matches`
/// checks in firestore.rules (the server is the final authority).
abstract final class MatchValidator {
  static const minTitle = 3;
  static const maxTitle = 80;
  static const maxText = 1000;
  static const maxPhotos = 5;
  static const maxPrice = 100000;
  static const minDuration = Duration(minutes: 30);
  static const maxDuration = Duration(hours: 6);

  /// Kick-off must be at least this far in the future when publishing.
  static const minLeadTime = Duration(minutes: 30);

  /// First problem with [step], or null if it's complete.
  static String? validateStep(
    CreateMatchStep step,
    MatchDraft d, {
    required DateTime now,
  }) {
    return switch (step) {
      CreateMatchStep.title => _title(d.title),
      CreateMatchStep.venue => _venue(d),
      CreateMatchStep.location => null, // map pin arrives with Google Maps
      CreateMatchStep.date => _date(d.date, now),
      CreateMatchStep.startTime => _start(d, now),
      CreateMatchStep.endTime => _end(d),
      CreateMatchStep.format => null,
      CreateMatchStep.maxPlayers => _maxPlayers(d.maxPlayers),
      CreateMatchStep.positions =>
        d.specificPositionsTotal > d.maxPlayers
            ? 'Positions add up to ${d.specificPositionsTotal}, '
                  'but the match has ${d.maxPlayers} places'
            : null,
      CreateMatchStep.lineup =>
        d.openSpots < 0
            ? '${d.confirmedCount} players confirmed, but the match has '
                  '${d.maxPlayers} places'
            : null,
      CreateMatchStep.skill => null,
      CreateMatchStep.price =>
        d.priceAmount < 0 || d.priceAmount > maxPrice
            ? 'Enter a price between 0 and $maxPrice'
            : null,
      CreateMatchStep.description => _length(d.description, 'Description'),
      CreateMatchStep.rules => _length(d.rules, 'Rules'),
      CreateMatchStep.photos =>
        d.photos.length > maxPhotos ? 'Up to $maxPhotos photos' : null,
      CreateMatchStep.review => validateForPublish(d, now: now).firstOrNull,
    };
  }

  /// Every problem that blocks publishing, in step order.
  static List<String> validateForPublish(
    MatchDraft d, {
    required DateTime now,
  }) => [
    for (final step in CreateMatchStep.values)
      if (step != CreateMatchStep.review) ?validateStep(step, d, now: now),
  ];

  /// The first step with a problem, to jump back to from review.
  static CreateMatchStep? firstInvalidStep(
    MatchDraft d, {
    required DateTime now,
  }) {
    for (final step in CreateMatchStep.values) {
      if (step == CreateMatchStep.review) continue;
      if (validateStep(step, d, now: now) != null) return step;
    }
    return null;
  }

  static String? _title(String title) {
    final t = title.trim();
    if (t.length < minTitle) return 'Give the match a name';
    if (t.length > maxTitle) return 'Keep the name under $maxTitle characters';
    return null;
  }

  static String? _venue(MatchDraft d) {
    final venue = d.venue;
    if (venue == null || venue.name.trim().isEmpty) {
      return 'Enter the venue name';
    }
    if (venue.city.trim().isEmpty) return 'Enter the city';
    return null;
  }

  static String? _date(DateTime? date, DateTime now) {
    if (date == null) return 'Pick a date';
    final today = DateTime(now.year, now.month, now.day);
    if (DateTime(date.year, date.month, date.day).isBefore(today)) {
      return 'That date has passed';
    }
    return null;
  }

  static String? _start(MatchDraft d, DateTime now) {
    final start = d.startAt;
    if (start == null) return 'Pick a kick-off time';
    if (start.isBefore(now.add(minLeadTime))) {
      return 'Kick-off must be at least 30 minutes from now';
    }
    return null;
  }

  static String? _end(MatchDraft d) {
    final start = d.startAt;
    final end = d.endAt;
    if (start == null || end == null) return 'Pick when the match ends';
    final length = end.difference(start);
    if (length < minDuration) return 'Matches must be at least 30 minutes';
    if (length > maxDuration) return 'Matches can be at most 6 hours';
    return null;
  }

  static String? _maxPlayers(int n) {
    const min = AppConstants.minPlayersPerMatch;
    const max = AppConstants.maxPlayersPerMatch;
    return n < min || n > max ? 'Choose between $min and $max players' : null;
  }

  static String? _length(String text, String label) => text.length > maxText
      ? '$label is too long ($maxText characters max)'
      : null;
}
