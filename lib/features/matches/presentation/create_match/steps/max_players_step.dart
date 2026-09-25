import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/count_stepper.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class MaxPlayersStep extends StatelessWidget {
  const MaxPlayersStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Total players including both teams. '
          '${draft.format.label} usually has ${draft.format.defaultMaxPlayers}; '
          'add extras for rotating subs.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        CountStepper(
          key: const Key('maxPlayersStepper'),
          value: draft.maxPlayers,
          min: AppConstants.minPlayersPerMatch,
          max: AppConstants.maxPlayersPerMatch,
          label: 'players',
          onChanged: (n) => onChanged((d) => d.copyWith(maxPlayers: n)),
        ),
      ],
    );
  }
}
