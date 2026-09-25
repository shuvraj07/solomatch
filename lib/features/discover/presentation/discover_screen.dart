import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../shared/widgets/match_card.dart';
import '../data/discover_providers.dart';
import '../domain/match_filters.dart';
import '../domain/matching_service.dart';
import 'filters_sheet.dart';

/// Search, filter and recommended ordering over upcoming matches.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  late final _search = TextEditingController(
    text: ref.read(discoverFiltersProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(MatchFilters Function(MatchFilters f) change) =>
      ref.read(discoverFiltersProvider.notifier).update(change);

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<MatchFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FiltersSheet(initial: ref.read(discoverFiltersProvider)),
    );
    if (result != null) _update((_) => result);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(discoverFiltersProvider);
    final results = ref.watch(discoverResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          TextButton.icon(
            key: const Key('venuesButton'),
            onPressed: () => context.push(AppRoutes.venues),
            icon: const Icon(Icons.stadium_rounded),
            label: const Text('Venues'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              key: const Key('discoverSearchField'),
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (q) => _update((f) => f.copyWith(query: q)),
              decoration: InputDecoration(
                hintText: 'Search matches, venues or areas',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: filters.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          _update((f) => f.copyWith(query: ''));
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              key: const Key('dateChips'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              children: [
                Badge(
                  isLabelVisible: filters.activeCount > 0,
                  label: Text('${filters.activeCount}'),
                  child: ActionChip(
                    key: const Key('openFiltersButton'),
                    avatar: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Filters'),
                    onPressed: _openFilters,
                  ),
                ),
                for (final d in DateFilter.values) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(
                    key: Key('date_${d.name}'),
                    label: Text(d.label),
                    selected: filters.date == d,
                    onSelected: (_) => _update((f) => f.copyWith(date: d)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xs,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(switch (results) {
                    AsyncData(value: final l) =>
                      '${l.length} ${l.length == 1 ? 'match' : 'matches'}',
                    _ => '',
                  }, style: theme.textTheme.labelLarge),
                ),
                PopupMenuButton<DiscoverSort>(
                  key: const Key('sortMenu'),
                  initialValue: filters.sort,
                  onSelected: (s) => _update((f) => f.copyWith(sort: s)),
                  itemBuilder: (_) => [
                    for (final s in DiscoverSort.values)
                      PopupMenuItem(value: s, child: Text(s.label)),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort_rounded, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(filters.sort.label),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (results) {
              AsyncData(value: final list) when list.isEmpty =>
                const PlaceholderView(
                  icon: Icons.search_off_rounded,
                  title: 'No matches found',
                  message:
                      'Try another day, fewer filters or a different search.',
                ),
              AsyncData(value: final list) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xxl * 2,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final (:match, :fit) = list[i];
                  final recommended =
                      fit.score >= MatchingService.recommendedThreshold;
                  return MatchCard(
                    key: Key('discover_${match.id}'),
                    match: match,
                    note: recommended && fit.reasons.isNotEmpty
                        ? '✨ ${fit.reasons.take(3).join(' · ')}'
                        : null,
                    onTap: () => context.push(AppRoutes.matchDetails(match.id)),
                  );
                },
              ),
              AsyncError(:final error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(errorMessage(error)),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}
