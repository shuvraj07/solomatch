import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../models/position_group.dart';

extension PositionGroupColor on PositionGroup {
  Color get color => switch (this) {
    PositionGroup.gk => AppColors.goalkeeper,
    PositionGroup.def => AppColors.defender,
    PositionGroup.mid => AppColors.midfielder,
    PositionGroup.fwd => AppColors.forward,
    PositionGroup.any => AppColors.anyPosition,
  };
}

/// Colored pill such as "🧤 1 GK" or "CAM", tinted by position group.
class PositionBadge extends StatelessWidget {
  const PositionBadge({
    super.key,
    required this.group,
    required this.label,
    this.showEmoji = false,
  });

  final PositionGroup group;
  final String label;
  final bool showEmoji;

  @override
  Widget build(BuildContext context) {
    final color = group.color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        showEmoji ? '${group.emoji} $label' : label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Color.lerp(color, Colors.black, 0.25),
        ),
      ),
    );
  }
}
