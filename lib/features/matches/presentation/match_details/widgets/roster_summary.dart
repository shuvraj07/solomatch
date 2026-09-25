import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/position_group.dart';
import '../../../../../shared/widgets/player_avatar.dart';
import '../../../../../shared/widgets/position_badge.dart';
import '../../../../match_requests/domain/roster_entry.dart';
import '../../../domain/football_match.dart';

/// "MATCH ROSTER" card: filled/needed and player names per position group,
/// plus spots remaining. Counts come from the match document; names from
/// the roster subcollection. Both are live.
class RosterSummary extends StatelessWidget {
  const RosterSummary({super.key, required this.match, required this.roster});

  final FootballMatch match;
  final List<RosterEntry> roster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = match.spotsRemaining;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'MATCH ROSTER',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Text(
                  '${match.currentPlayers}/${match.maxPlayers}',
                  key: const Key('rosterCount'),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: match.maxPlayers == 0
                    ? 0
                    : match.currentPlayers / match.maxPlayers,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final group in PositionGroup.values)
              if (match.slots[group].needed > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            group.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: Text(group.label)),
                          PositionBadge(
                            group: group,
                            label:
                                '${match.slots[group].filled}/${match.slots[group].needed}',
                          ),
                        ],
                      ),
                      for (final entry in roster.where((e) => e.group == group))
                        InkWell(
                          key: Key('rosterPlayer_${entry.player.uid}'),
                          onTap: () => context.push(
                            AppRoutes.playerProfile(entry.player.uid),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 36,
                              top: AppSpacing.xs,
                              bottom: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                PlayerAvatar(
                                  name: entry.player.name,
                                  photoUrl: entry.player.photoUrl,
                                  radius: 12,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    entry.player.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  [
                                    ?match.report
                                        ?.lineFor(entry.player.uid)
                                        .summary,
                                    entry.player.primaryPosition.shortLabel,
                                  ].where((s) => s.isNotEmpty).join('  '),
                                  key: Key('rosterLine_${entry.player.uid}'),
                                  style: TextStyle(color: muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            if (match.guestCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 36, top: AppSpacing.xs),
                child: Text(
                  '+ ${match.guestCount} '
                  '${match.guestCount == 1 ? 'guest' : 'guests'} '
                  '(not on SoloMatch)',
                  key: const Key('rosterGuests'),
                  style: TextStyle(color: muted),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              spots == 0
                  ? 'No spots left'
                  : '$spots ${spots == 1 ? 'spot' : 'spots'} remaining',
              key: const Key('spotsRemaining'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
