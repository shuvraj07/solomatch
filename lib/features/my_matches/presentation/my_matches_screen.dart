import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../data/my_matches_providers.dart';
import '../domain/my_match_entry.dart';
import 'widgets/my_match_tile.dart';

/// Upcoming / Requested / Played / Created. Everything is live: an accept,
/// a cancellation or the final whistle moves matches between tabs.
class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  static const _empty = {
    MyMatchesTab.upcoming: (
      Icons.event_available_rounded,
      'Nothing coming up',
      'Matches you play in or organize show up here.',
    ),
    MyMatchesTab.requested: (
      Icons.hourglass_empty_rounded,
      'No pending requests',
      'Ask to join a match from Home.',
    ),
    MyMatchesTab.played: (
      Icons.emoji_events_outlined,
      'No matches played yet',
      'After a match, come here to vote Man of the Match.',
    ),
    MyMatchesTab.created: (
      Icons.add_circle_outline_rounded,
      "You haven't organized a match",
      'Tap + to post one.',
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(myMatchesProvider);

    return DefaultTabController(
      length: MyMatchesTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My matches'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final t in MyMatchesTab.values)
                Tab(
                  key: Key('tab_${t.name}'),
                  text: switch (tabs.value?[t]?.length) {
                    final n? when n > 0 => '${t.label} ($n)',
                    _ => t.label,
                  },
                ),
            ],
          ),
        ),
        body: switch (tabs) {
          AsyncData(value: final byTab) => TabBarView(
            children: [
              for (final t in MyMatchesTab.values)
                _TabList(entries: byTab[t] ?? const [], empty: _empty[t]!),
            ],
          ),
          AsyncError(:final error) => Center(child: Text(errorMessage(error))),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _TabList extends StatelessWidget {
  const _TabList({required this.entries, required this.empty});

  final List<MyMatchEntry> entries;
  final (IconData, String, String) empty;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      final (icon, title, message) = empty;
      return PlaceholderView(icon: icon, title: title, message: message);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => MyMatchTile(entry: entries[i]),
    );
  }
}
