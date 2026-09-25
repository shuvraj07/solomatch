import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/preferred_foot.dart';
import '../../../../shared/models/skill_level.dart';
import '../onboarding_controller.dart';

class GameStep extends ConsumerWidget {
  const GameStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final theme = Theme.of(context);
    final skill = state.skillLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Skill level', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<SkillLevel>(
          key: const Key('skillLevelSelector'),
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          segments: [
            for (final level in SkillLevel.playerLevels)
              ButtonSegment(value: level, label: Text(level.label)),
          ],
          selected: {?skill},
          onSelectionChanged: (v) => controller.update(
            (s) => s.copyWith(skillLevel: v.isEmpty ? s.skillLevel : v.first),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Preferred foot', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<PreferredFoot>(
          showSelectedIcon: false,
          segments: [
            for (final foot in PreferredFoot.values)
              ButtonSegment(value: foot, label: Text(foot.label)),
          ],
          selected: {state.preferredFoot},
          onSelectionChanged: (v) =>
              controller.update((s) => s.copyWith(preferredFoot: v.first)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text('Years playing', style: theme.textTheme.titleMedium),
            ),
            IconButton.outlined(
              tooltip: 'Fewer years',
              onPressed: state.yearsPlaying == 0
                  ? null
                  : () => controller.update(
                      (s) => s.copyWith(yearsPlaying: s.yearsPlaying - 1),
                    ),
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${state.yearsPlaying}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
            IconButton.outlined(
              tooltip: 'More years',
              onPressed: state.yearsPlaying >= 60
                  ? null
                  : () => controller.update(
                      (s) => s.copyWith(yearsPlaying: s.yearsPlaying + 1),
                    ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          initialValue: state.heightCm?.toString() ?? '',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (v) =>
              controller.update((s) => s.copyWith(heightCm: int.tryParse(v))),
          decoration: const InputDecoration(
            labelText: 'Height (optional)',
            suffixText: 'cm',
          ),
        ),
      ],
    );
  }
}
