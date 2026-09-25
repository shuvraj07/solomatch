import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/models/position_group.dart';
import '../../../../../shared/models/price.dart';
import '../../../domain/create_match_step.dart';
import '../../../domain/match_draft.dart';

/// Summary of everything entered, with a jump back to each step.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.draft,
    required this.problems,
    required this.onEdit,
  });

  final MatchDraft draft;
  final List<String> problems;
  final ValueChanged<CreateMatchStep> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = draft.startAt;
    final end = draft.endAt;
    final slots = draft.slots;
    final confirmedNames = [
      if (draft.organizerPlaying) 'You',
      for (final l in draft.lineup) l.name,
      if (draft.guestCount > 0)
        '${draft.guestCount} ${draft.guestCount == 1 ? 'guest' : 'guests'}',
    ];
    final needs = [
      for (final g in PositionGroup.values)
        if (slots[g].needed > 0)
          '${g.emoji} ${slots[g].needed} ${g.shortLabel}',
    ].join('  ');

    Widget row(CreateMatchStep step, String label, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: theme.textTheme.labelMedium),
      subtitle: Text(
        value.isEmpty ? '—' : value,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: IconButton(
        tooltip: 'Edit $label',
        icon: const Icon(Icons.edit_outlined),
        onPressed: () => onEdit(step),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (problems.isNotEmpty)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fix before publishing',
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final p in problems) Text('• $p'),
                ],
              ),
            ),
          ),
        row(CreateMatchStep.title, 'Match', draft.title.trim()),
        row(
          CreateMatchStep.venue,
          'Venue',
          [
            draft.venue?.shortLabel,
            draft.venue?.city,
            draft.isIndoor ? 'Indoor' : 'Outdoor',
          ].nonNulls.join(' · '),
        ),
        row(
          CreateMatchStep.date,
          'When',
          start == null || end == null
              ? ''
              : '${Formatters.longDate(start)}\n'
                    '${Formatters.timeRange(start, end)}',
        ),
        row(
          CreateMatchStep.format,
          'Format',
          '${draft.format.label} · ${draft.maxPlayers} players',
        ),
        row(CreateMatchStep.positions, 'Positions', needs),
        row(
          CreateMatchStep.lineup,
          'Already confirmed',
          draft.confirmedCount == 0
              ? 'Nobody yet: all ${draft.maxPlayers} spots open'
              : '${confirmedNames.join(', ')}\n'
                    '${draft.openSpots} spots open for requests',
        ),
        row(CreateMatchStep.skill, 'Skill level', draft.skillLevel.label),
        row(
          CreateMatchStep.price,
          'Price',
          Price(amount: draft.priceAmount).display,
        ),
        row(CreateMatchStep.description, 'Description', draft.description),
        row(CreateMatchStep.rules, 'Rules', draft.rules),
        row(
          CreateMatchStep.photos,
          'Photos',
          draft.photos.isEmpty ? '' : '${draft.photos.length} added',
        ),
      ],
    );
  }
}
