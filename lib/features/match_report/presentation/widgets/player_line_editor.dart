import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/count_stepper.dart';
import '../../../../shared/models/player_card.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../domain/match_report.dart';

/// Goals / assists / cards editor for one player in the match report.
class PlayerLineEditor extends StatelessWidget {
  const PlayerLineEditor({
    super.key,
    required this.player,
    required this.line,
    required this.onChanged,
  });

  final PlayerCard player;
  final PlayerMatchLine line;
  final ValueChanged<PlayerMatchLine> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String label, Widget control) => Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        control,
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                PlayerAvatar(
                  name: player.name,
                  photoUrl: player.photoUrl,
                  radius: 18,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(player.name, style: theme.textTheme.titleMedium),
                ),
                Text(line.summary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            row(
              '⚽ Goals',
              CountStepper(
                key: Key('goals_${player.uid}'),
                value: line.goals,
                max: PlayerMatchLine.maxGoals,
                label: 'goals',
                onChanged: (n) => onChanged(line.copyWith(goals: n)),
              ),
            ),
            row(
              '🅰️ Assists',
              CountStepper(
                key: Key('assists_${player.uid}'),
                value: line.assists,
                max: PlayerMatchLine.maxAssists,
                label: 'assists',
                onChanged: (n) => onChanged(line.copyWith(assists: n)),
              ),
            ),
            row(
              '🟨 Yellow cards',
              CountStepper(
                key: Key('yellow_${player.uid}'),
                value: line.yellowCards,
                max: PlayerMatchLine.maxYellowCards,
                label: 'yellow cards',
                onChanged: (n) => onChanged(line.copyWith(yellowCards: n)),
              ),
            ),
            SwitchListTile(
              key: Key('red_${player.uid}'),
              contentPadding: EdgeInsets.zero,
              title: const Text('🟥 Red card'),
              value: line.redCard,
              onChanged: (v) => onChanged(line.copyWith(redCard: v)),
            ),
          ],
        ),
      ),
    );
  }
}
