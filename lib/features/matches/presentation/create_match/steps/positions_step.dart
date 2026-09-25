import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/count_stepper.dart';
import '../../../../../shared/models/position_group.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class PositionsStep extends StatelessWidget {
  const PositionsStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flexible = draft.maxPlayers - draft.specificPositionsTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How many of each position do you need? Everything else is open '
          'to any position. Players can still request any match.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final group in PositionGroup.specific)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(group.label, style: theme.textTheme.titleMedium),
                ),
                CountStepper(
                  key: Key('positionStepper_${group.name}'),
                  value: draft.neededPositions[group] ?? 0,
                  max: draft.maxPlayers,
                  label: group.label.toLowerCase(),
                  onChanged: (n) => onChanged(
                    (d) => d.copyWith(
                      neededPositions: {...d.neededPositions, group: n},
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: AppSpacing.xxl),
        Text(
          flexible >= 0
              ? '${PositionGroup.any.emoji}  Any position: $flexible'
              : 'Too many positions: remove ${-flexible}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: flexible >= 0 ? null : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
