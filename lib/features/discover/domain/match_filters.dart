import '../../../shared/models/match_format.dart';
import '../../../shared/models/position_group.dart';
import '../../../shared/models/skill_level.dart';
import '../../matches/domain/football_match.dart';

/// Date ranges offered as quick chips on Discover.
enum DateFilter {
  any('Any day'),
  today('Today'),
  tomorrow('Tomorrow'),
  thisWeek('Next 7 days'),
  weekend('Weekend');

  const DateFilter(this.label);

  final String label;

  bool includes(DateTime start, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(start.year, start.month, start.day);
    final offset = day.difference(today).inDays;
    return switch (this) {
      any => true,
      DateFilter.today => offset == 0,
      tomorrow => offset == 1,
      thisWeek => offset >= 0 && offset < 7,
      // The coming Saturday and Sunday (or this one, if it's the weekend).
      weekend =>
        offset >= 0 &&
            offset < 7 &&
            (start.weekday == DateTime.saturday ||
                start.weekday == DateTime.sunday),
    };
  }
}

/// How Discover orders its results.
enum DiscoverSort {
  recommended('Recommended'),
  soonest('Soonest');

  const DiscoverSort(this.label);

  final String label;
}

/// Everything the Discover screen can filter on. Applied on the device to
/// the upcoming matches (Firestore has no full-text search).
class MatchFilters {
  const MatchFilters({
    this.query = '',
    this.date = DateFilter.any,
    this.formats = const {},
    this.skill,
    this.position,
    this.freeOnly = false,
    this.indoor,
    this.hideFull = true,
    this.sort = DiscoverSort.recommended,
  });

  /// Matched against title, venue name, address and city.
  final String query;
  final DateFilter date;

  /// Empty means any format.
  final Set<MatchFormat> formats;

  /// Matches aimed at this level (plus "any level" matches).
  final SkillLevel? skill;

  /// Only matches with an open place for this position.
  final PositionGroup? position;
  final bool freeOnly;

  /// null = both, true = indoor only, false = outdoor only.
  final bool? indoor;
  final bool hideFull;
  final DiscoverSort sort;

  /// Filters in the sheet (not search, date or sort) that differ from the
  /// defaults. Shown as a badge on the Filters button.
  int get activeCount => [
    formats.isNotEmpty,
    skill != null,
    position != null,
    freeOnly,
    indoor != null,
    !hideFull,
  ].where((on) => on).length;

  bool accepts(FootballMatch m, DateTime now) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = [
        m.title,
        m.venue.name,
        m.venue.address,
        m.venue.city,
      ].join(' ').toLowerCase();
      if (!q.split(RegExp(r'\s+')).every(haystack.contains)) return false;
    }
    if (!date.includes(m.startAt, now)) return false;
    if (formats.isNotEmpty && !formats.contains(m.format)) return false;
    if (skill case final s?
        when m.skillLevel != SkillLevel.any && m.skillLevel != s) {
      return false;
    }
    if (position case final p?
        when m.slots.openIn(p) == 0 && m.slots.openIn(PositionGroup.any) == 0) {
      return false;
    }
    if (freeOnly && m.price.amount > 0) return false;
    if (indoor case final i? when m.isIndoor != i) return false;
    if (hideFull && m.isFull) return false;
    return true;
  }

  MatchFilters copyWith({
    String? query,
    DateFilter? date,
    Set<MatchFormat>? formats,
    SkillLevel? Function()? skill,
    PositionGroup? Function()? position,
    bool? freeOnly,
    bool? Function()? indoor,
    bool? hideFull,
    DiscoverSort? sort,
  }) => MatchFilters(
    query: query ?? this.query,
    date: date ?? this.date,
    formats: formats ?? this.formats,
    skill: skill != null ? skill() : this.skill,
    position: position != null ? position() : this.position,
    freeOnly: freeOnly ?? this.freeOnly,
    indoor: indoor != null ? indoor() : this.indoor,
    hideFull: hideFull ?? this.hideFull,
    sort: sort ?? this.sort,
  );

  /// Clears the sheet filters but keeps search, date and sort.
  MatchFilters reset() => MatchFilters(query: query, date: date, sort: sort);
}
