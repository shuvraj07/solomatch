import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/availability.dart';

/// 7 × 3 grid of days and time bands; tap a cell to toggle it.
class AvailabilityGrid extends StatelessWidget {
  const AvailabilityGrid({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Availability value;
  final ValueChanged<Availability> onChanged;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget cell(int weekday, TimeBand band) {
      final on = value.contains(weekday, band);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Semantics(
            label: '${_days[weekday - 1]} ${band.label}',
            selected: on,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () => onChanged(value.toggle(weekday, band)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: on ? scheme.primary : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: on
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: scheme.onPrimary,
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 44),
            for (final band in TimeBand.values)
              Expanded(
                child: Column(
                  children: [
                    Text(band.label, style: theme.textTheme.labelMedium),
                    Text(band.hint, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var day = 1; day <= 7; day++)
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(_days[day - 1], style: theme.textTheme.labelLarge),
              ),
              for (final band in TimeBand.values) cell(day, band),
            ],
          ),
      ],
    );
  }
}
