import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/position.dart';
import '../../../../shared/models/position_group.dart';
import '../../../../shared/widgets/position_badge.dart';

/// Chips for all positions, grouped GK / DEF / MID / FWD.
///
/// Single-select when [multiSelect] is false (tapping selects), multi-select
/// otherwise (tapping toggles). [disabled] positions are shown but inert.
class PositionChips extends StatelessWidget {
  const PositionChips({
    super.key,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
    this.disabled = const {},
  });

  final Set<Position> selected;
  final ValueChanged<Position> onTap;
  final bool multiSelect;
  final Set<Position> disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in PositionGroup.specific) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              '${group.emoji}  ${group.label}',
              style: theme.textTheme.labelLarge,
            ),
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final position in Position.values.where(
                (p) => p.group == group,
              ))
                _chip(position, group),
            ],
          ),
        ],
      ],
    );
  }

  Widget _chip(Position position, PositionGroup group) {
    final isSelected = selected.contains(position);
    final enabled = !disabled.contains(position);
    final label = Text('${position.label} (${position.shortLabel})');
    final color = group.color.withValues(alpha: 0.2);

    return multiSelect
        ? FilterChip(
            label: label,
            selected: isSelected,
            selectedColor: color,
            onSelected: enabled ? (_) => onTap(position) : null,
          )
        : ChoiceChip(
            label: label,
            selected: isSelected,
            selectedColor: color,
            onSelected: enabled ? (_) => onTap(position) : null,
          );
  }
}
