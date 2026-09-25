import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/clock_provider.dart';
import '../../../app/session/session_provider.dart';
import '../../matches/data/match_providers.dart';
import '../../matches/domain/football_match.dart';
import '../domain/match_filters.dart';
import '../domain/matching_service.dart';

/// Discover's filters. Not auto-disposed, so they survive tab switches.
class DiscoverFilters extends Notifier<MatchFilters> {
  @override
  MatchFilters build() => const MatchFilters();

  void update(MatchFilters Function(MatchFilters f) change) =>
      state = change(state);
}

final discoverFiltersProvider = NotifierProvider<DiscoverFilters, MatchFilters>(
  DiscoverFilters.new,
);

/// The pool Discover filters: the next 100 upcoming matches.
final discoverPoolProvider = StreamProvider.autoDispose<List<FootballMatch>>(
  (ref) => ref.watch(matchRepositoryProvider).watchUpcomingMatches(limit: 100),
);

/// Filtered and ordered results, each with its fit for the current player.
final discoverResultsProvider =
    Provider.autoDispose<AsyncValue<List<RankedMatch>>>((ref) {
      final filters = ref.watch(discoverFiltersProvider);
      final profile = ref.watch(currentProfileProvider);
      final now = ref.watch(clockProvider)();
      return ref.watch(discoverPoolProvider).whenData((pool) {
        final visible = pool.where((m) => filters.accepts(m, now));
        if (profile == null) {
          return [
            for (final m in visible)
              (match: m, fit: (score: 0, reasons: const <String>[])),
          ];
        }
        final ranked = MatchingService.rank(profile, visible, now);
        if (filters.sort == DiscoverSort.soonest) {
          ranked.sort((a, b) => a.match.startAt.compareTo(b.match.startAt));
        }
        return ranked;
      });
    });
