import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

/// Kick-off (isStart) or end time. Offers quick picks plus a full picker.
class TimeStep extends StatelessWidget {
  const TimeStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.isStart,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;
  final bool isStart;

  static const _kickOffPicks = [
    6 * 60,
    7 * 60,
    16 * 60,
    17 * 60,
    18 * 60,
    19 * 60,
  ];
  static const _durationPicks = [60, 90, 120];

  int? get _value => isStart ? draft.startMinutes : draft.endMinutes;

  void _set(int minutes) => onChanged(
    (d) => isStart
        ? d.copyWith(startMinutes: minutes)
        : d.copyWith(endMinutes: minutes),
  );

  Future<void> _pick(BuildContext context) async {
    final current = _value ?? (isStart ? 18 * 60 : 20 * 60);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) _set(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = _value;
    final start = draft.startMinutes;
    final duration = draft.startAt != null && draft.endAt != null
        ? draft.endAt!.difference(draft.startAt!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: Key(isStart ? 'pickStartTime' : 'pickEndTime'),
          onPressed: () => _pick(context),
          icon: const Icon(Icons.schedule_rounded),
          label: Text(
            value == null ? 'Choose time' : Formatters.minutesOfDay(value),
            style: theme.textTheme.titleLarge,
          ),
        ),
        if (!isStart && duration != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Match length: ${Formatters.duration(duration)}',
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          isStart ? 'Popular kick-off times' : 'Quick pick',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: isStart
              ? [
                  for (final m in _kickOffPicks)
                    ChoiceChip(
                      label: Text(Formatters.minutesOfDay(m)),
                      selected: value == m,
                      onSelected: (_) => _set(m),
                    ),
                ]
              : [
                  if (start != null)
                    for (final length in _durationPicks)
                      ChoiceChip(
                        label: Text(
                          Formatters.duration(Duration(minutes: length)),
                        ),
                        selected: value == (start + length) % (24 * 60),
                        onSelected: (_) => _set((start + length) % (24 * 60)),
                      ),
                ],
        ),
      ],
    );
  }
}
