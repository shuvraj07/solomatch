import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/matches/domain/match_status.dart';

/// Small colored pill showing a match's status.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final MatchStatus status;

  Color get _color => switch (status) {
    MatchStatus.published => AppColors.statusOpen,
    MatchStatus.filling => AppColors.statusFilling,
    MatchStatus.full => AppColors.statusFull,
    MatchStatus.started ||
    MatchStatus.completed ||
    MatchStatus.cancelled => AppColors.statusNeutral,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Color.lerp(_color, Colors.black, 0.2),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
