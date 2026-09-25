import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../features/matches/domain/football_match.dart';
import 'position_badge.dart';
import 'status_chip.dart';

/// Summary card used in Home, Discover and My Matches lists.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.onTap,
    this.distanceLabel,
  });

  final FootballMatch match;
  final VoidCallback onTap;

  /// e.g. "2.4 km". Filled in once location-aware discovery lands.
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final needs = match.slots.openByGroup;
    final distance = distanceLabel;

    Widget line(String emoji, String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        '$emoji  $text',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: muted),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '⚽ ${match.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(status: match.status),
                ],
              ),
              line('📍', [match.venue.shortLabel, ?distance].join(' · ')),
              line(
                '🗓',
                '${Formatters.shortDate(match.startAt)} · '
                    '${Formatters.timeRange(match.startAt, match.endAt)}',
              ),
              line(
                '👥',
                '${match.currentPlayers}/${match.maxPlayers} players · '
                    '${match.format.label} · ${match.price.display}',
              ),
              if (needs.isNotEmpty && !match.isFull) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final e in needs.entries)
                      PositionBadge(
                        group: e.key,
                        label: '${e.value} ${e.key.shortLabel}',
                        showEmoji: true,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
