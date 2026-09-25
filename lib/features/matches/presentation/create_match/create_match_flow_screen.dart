import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../domain/create_match_step.dart';
import '../../domain/match_draft.dart';
import '../../domain/match_validator.dart';
import 'create_match_controller.dart';
import 'steps/date_step.dart';
import 'steps/format_step.dart';
import 'steps/lineup_step.dart';
import 'steps/location_step.dart';
import 'steps/long_text_step.dart';
import 'steps/max_players_step.dart';
import 'steps/photos_step.dart';
import 'steps/positions_step.dart';
import 'steps/price_step.dart';
import 'steps/review_step.dart';
import 'steps/skill_step.dart';
import 'steps/time_step.dart';
import 'steps/title_step.dart';
import 'steps/venue_step.dart';

enum _ExitChoice { save, discard }

/// The step-by-step create flow for one [MatchDraft].
class CreateMatchFlowScreen extends ConsumerWidget {
  const CreateMatchFlowScreen({super.key, required this.initialDraft});

  final MatchDraft initialDraft;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object catch (error) {
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  Future<void> _pickPhoto(CreateMatchController controller) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file != null) await controller.addPhoto(await file.readAsBytes());
  }

  Future<void> _exit(
    BuildContext context,
    CreateMatchController controller,
    bool dirty,
  ) async {
    if (!dirty) {
      context.pop();
      return;
    }
    final choice = await showDialog<_ExitChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this match as a draft?'),
        content: const Text('You can finish and publish it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.discard),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.save),
            child: const Text('Save draft'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice == _ExitChoice.save) {
      await _run(context, controller.saveDraft);
    }
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = createMatchControllerProvider(initialDraft);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final draft = state.draft;
    final step = state.step;
    final total = CreateMatchStep.values.length;
    final now = DateTime.now();

    final body = switch (step) {
      CreateMatchStep.title => TitleStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.venue => VenueStep(
        draft: draft,
        onChanged: controller.update,
        defaultCity: ref.watch(currentProfileProvider)?.city ?? '',
      ),
      CreateMatchStep.location => LocationStep(draft: draft),
      CreateMatchStep.date => DateStep(
        draft: draft,
        onChanged: controller.update,
        today: now,
      ),
      CreateMatchStep.startTime => TimeStep(
        draft: draft,
        onChanged: controller.update,
        isStart: true,
      ),
      CreateMatchStep.endTime => TimeStep(
        draft: draft,
        onChanged: controller.update,
        isStart: false,
      ),
      CreateMatchStep.format => FormatStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.maxPlayers => MaxPlayersStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.positions => PositionsStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.lineup => LineupStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.skill => SkillStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.price => PriceStep(
        draft: draft,
        onChanged: controller.update,
      ),
      CreateMatchStep.description => LongTextStep(
        label: 'Description',
        hint: 'Friendly weekly game, bring a light and a dark shirt…',
        initialValue: draft.description,
        onChanged: (v) => controller.update((d) => d.copyWith(description: v)),
      ),
      CreateMatchStep.rules => LongTextStep(
        label: 'Rules',
        hint: 'No slide tackles. Rolling subs every 10 minutes…',
        initialValue: draft.rules,
        onChanged: (v) => controller.update((d) => d.copyWith(rules: v)),
      ),
      CreateMatchStep.photos => PhotosStep(
        draft: draft,
        busy: state.busy,
        onAdd: () => _run(context, () => _pickPhoto(controller)),
        onRemove: controller.removePhoto,
      ),
      CreateMatchStep.review => ReviewStep(
        draft: draft,
        problems: MatchValidator.validateForPublish(draft, now: now),
        onEdit: controller.goTo,
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (step.isFirst) {
          _exit(context, controller, state.dirty);
        } else {
          controller.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: step.isFirst ? 'Close' : 'Back',
            icon: Icon(
              step.isFirst ? Icons.close_rounded : Icons.arrow_back_rounded,
            ),
            onPressed: step.isFirst
                ? () => _exit(context, controller, state.dirty)
                : controller.back,
          ),
          title: Text('Step ${step.index + 1} of $total'),
          actions: [
            TextButton(
              key: const Key('saveDraftButton'),
              onPressed: state.busy
                  ? null
                  : () => _run(context, () async {
                      await controller.saveDraft();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Draft saved')),
                        );
                      }
                    }),
              child: const Text('Save draft'),
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
                step.heading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Keyed so text fields are re-seeded from the draft per step.
              KeyedSubtree(key: ValueKey(step), child: body),
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
              key: const Key('createMatchNextButton'),
              label: step.isLast ? 'Publish match ⚽' : 'Continue',
              loading: state.busy,
              onPressed: step.isLast
                  ? () => _run(context, () async {
                      final id = await controller.publish();
                      if (context.mounted) {
                        context.pushReplacement(AppRoutes.matchDetails(id));
                      }
                    })
                  : () => _run(context, () async {
                      FocusScope.of(context).unfocus();
                      controller.next();
                    }),
            ),
          ),
        ),
      ),
    );
  }
}
