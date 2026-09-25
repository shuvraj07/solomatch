import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/position.dart';
import '../../../profile/domain/profile_rules.dart';
import '../../../profile/presentation/widgets/position_chips.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';

class PositionsStep extends ConsumerWidget {
  const PositionsStep({super.key});

  static OnboardingState _setPrimary(OnboardingState s, Position p) =>
      s.copyWith(
        primaryPosition: p,
        secondaryPositions: [
          for (final x in s.secondaryPositions)
            if (x != p) x,
        ],
      );

  static OnboardingState _toggleSecondary(OnboardingState s, Position p) {
    final list = [...s.secondaryPositions];
    if (!list.remove(p)) {
      if (list.length >= ProfileRules.maxSecondaryPositions) return s;
      list.add(p);
    }
    return s.copyWith(secondaryPositions: list);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final theme = Theme.of(context);
    final primary = state.primaryPosition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Main position', style: theme.textTheme.titleMedium),
        PositionChips(
          key: const Key('primaryPositionChips'),
          selected: {?primary},
          onTap: (p) => controller.update((s) => _setPrimary(s, p)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Also plays (up to ${ProfileRules.maxSecondaryPositions})',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'Organizers see these too. You can still request any match.',
          style: theme.textTheme.bodySmall,
        ),
        PositionChips(
          key: const Key('secondaryPositionChips'),
          multiSelect: true,
          selected: state.secondaryPositions.toSet(),
          disabled: {?primary},
          onTap: (p) => controller.update((s) => _toggleSecondary(s, p)),
        ),
      ],
    );
  }
}
