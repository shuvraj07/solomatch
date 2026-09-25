import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/placeholder_view.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/match_providers.dart';
import '../../domain/football_match.dart';
import '../../domain/match_action.dart';
import 'widgets/match_action_bar.dart';
import 'widgets/roster_summary.dart';

/// Live match page. Everything here comes from [matchProvider], so counts
/// and status change on screen the moment Firestore changes.
class MatchDetailsScreen extends ConsumerWidget {
  const MatchDetailsScreen({super.key, required this.matchId});

  final String matchId;

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this match?'),
        content: const Text(
          'Everyone who asked to join will see it as cancelled. '
          "This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep match'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel match'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(matchRepositoryProvider).cancelMatch(matchId);
    } on Object catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider(matchId));
    final uid = ref.watch(currentProfileProvider)?.uid ?? '';

    return switch (match) {
      AsyncData(value: final m?) => _Loaded(
        match: m,
        action: resolveMatchAction(m, uid),
        onCancel: () => _confirmCancel(context, ref),
      ),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const PlaceholderView(
          icon: Icons.search_off_rounded,
          title: 'Match not found',
          message: 'It may have been removed.',
        ),
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(errorMessage(error))),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.match,
    required this.action,
    required this.onCancel,
  });

  final FootballMatch match;
  final MatchAction action;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = match;

    Widget info(IconData icon, String title, [String? subtitle]) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    );

    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (action == MatchAction.organizer)
            PopupMenuButton<String>(
              key: const Key('matchMenu'),
              onSelected: (_) => onCancel(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'cancel', child: Text('Cancel match')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        children: [
          if (m.photos.isNotEmpty) ...[
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: m.photos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(m.photos[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          StatusChip(status: m.status),
          const SizedBox(height: AppSpacing.sm),
          Text(m.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              PlayerAvatar(
                name: m.organizer.name,
                photoUrl: m.organizer.photoUrl,
                radius: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Organized by ${m.organizer.name}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          info(
            Icons.place_rounded,
            m.venue.shortLabel,
            '${m.venue.city} · ${m.isIndoor ? 'Indoor' : 'Outdoor'}',
          ),
          info(
            Icons.event_rounded,
            Formatters.longDate(m.startAt),
            '${Formatters.timeRange(m.startAt, m.endAt)} · '
            '${Formatters.duration(m.duration)}',
          ),
          info(
            Icons.sports_soccer_rounded,
            '${m.format.label} · ${m.maxPlayers} players',
            'Skill: ${m.skillLevel.label}',
          ),
          info(Icons.payments_outlined, m.price.display, 'Per player'),
          const SizedBox(height: AppSpacing.md),
          RosterSummary(match: m),
          if (m.description.isNotEmpty) section('About', m.description),
          if (m.rules.isNotEmpty) section('Rules', m.rules),
        ],
      ),
      bottomNavigationBar: MatchActionBar(
        action: action,
        onRequestToJoin: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Join requests are coming in the next update.'),
          ),
        ),
      ),
    );
  }
}
