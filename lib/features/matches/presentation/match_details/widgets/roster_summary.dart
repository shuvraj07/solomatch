import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/position_group.dart';
import '../../../../../shared/widgets/position_badge.dart';
import '../../../domain/football_match.dart';

/// "MATCH ROSTER" card: filled/needed per position group and spots left.
/// Player names per slot arrive with the roster in Phase 4.
class RosterSummary extends StatelessWidget {
  const RosterSummary({super.key, required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = match.spotsRemaining;
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
                  child: Row(
                    children: [
                      Text(group.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(group.label)),
                      PositionBadge(
                        group: group,
                        label:
                            '${match.slots[group].filled}/${match.slots[group].needed}',
                      ),
                    ],
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
