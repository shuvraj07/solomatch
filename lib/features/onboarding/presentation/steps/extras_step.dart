import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../profile/domain/profile_options.dart';
import '../../../profile/domain/profile_rules.dart';
import '../../../profile/presentation/widgets/availability_grid.dart';
import '../onboarding_controller.dart';

class ExtrasStep extends ConsumerWidget {
  const ExtrasStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Languages', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final language in ProfileOptions.languages)
              FilterChip(
                label: Text(language),
                selected: state.languages.contains(language),
                onSelected: (on) => controller.update(
                  (s) => s.copyWith(
                    languages: on
                        ? [...s.languages, language]
                        : [
                            for (final l in s.languages)
                              if (l != language) l,
                          ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('When can you usually play?', style: theme.textTheme.titleMedium),
        Text(
          'Used to recommend matches. Optional.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        AvailabilityGrid(
          value: state.availability,
          onChanged: (a) =>
              controller.update((s) => s.copyWith(availability: a)),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          initialValue: state.bio,
          maxLines: 4,
          maxLength: ProfileRules.maxBioLength,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => controller.update((s) => s.copyWith(bio: v)),
          decoration: const InputDecoration(
            labelText: 'Bio (optional)',
            hintText: 'Box-to-box midfielder, love weekend 5-a-side…',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
