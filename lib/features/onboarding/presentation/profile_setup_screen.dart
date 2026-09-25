import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/account_mode.dart';
import '../../../app/session/sign_out.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/loading_button.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'steps/basics_step.dart';
import 'steps/details_step.dart';
import 'steps/extras_step.dart';
import 'steps/game_step.dart';
import 'steps/positions_step.dart';

/// New users land here after signing up. Finishing creates `players/{uid}`,
/// which flips the session to Ready and the router moves on to Home.
class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  static Widget _stepBody(OnboardingStep step) => switch (step) {
    OnboardingStep.basics => const BasicsStep(),
    OnboardingStep.details => const DetailsStep(),
    OnboardingStep.positions => const PositionsStep(),
    OnboardingStep.game => const GameStep(),
    OnboardingStep.extras => const ExtrasStep(),
  };

  Future<void> _next(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    try {
      await ref.read(onboardingControllerProvider.notifier).next();
    } on Object catch (error) {
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final step = state.step;
    final total = OnboardingStep.values.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: step.index == 0
              ? null
              : IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: controller.back,
                ),
          automaticallyImplyLeading: false,
          title: Text('Step ${step.index + 1} of $total'),
          actions: [
            if (step.index == 0)
              TextButton(
                key: const Key('switchToOwnerSetup'),
                onPressed: () => ref
                    .read(accountModeProvider.notifier)
                    .select(AccountMode.owner),
                child: const Text('I own a venue'),
              ),
            TextButton(
              onPressed: () => ref.read(signOutProvider)(),
              child: const Text('Sign out'),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (step.index + 1) / total),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Keyed so each step gets fresh form fields seeded from state.
              KeyedSubtree(key: ValueKey(step), child: _stepBody(step)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: LoadingButton(
              key: const Key('onboardingNextButton'),
              label: step.isLast ? "Let's play ⚽" : 'Continue',
              loading: state.busy,
              onPressed: () => _next(context, ref),
            ),
          ),
        ),
      ),
    );
  }
}
