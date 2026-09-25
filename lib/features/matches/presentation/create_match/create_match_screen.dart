import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../data/match_providers.dart';
import '../../domain/match_draft.dart';

/// Entry point of Create Match: start a new match or continue a draft.
class CreateMatchScreen extends ConsumerWidget {
  const CreateMatchScreen({super.key});

  void _open(BuildContext context, MatchDraft draft) =>
      context.pushReplacement(AppRoutes.createMatchFlow, extra: draft);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final drafts = ref.watch(myDraftsProvider(profile.uid));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create match')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚽', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Post a match', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Pick a venue and time, say which positions you need, '
                    'and players nearby can ask to join.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: const Key('newMatchButton'),
                    onPressed: () => _open(
                      context,
                      MatchDraft(
                        id: ref.read(matchRepositoryProvider).newMatchId(),
                        organizerId: profile.uid,
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New match'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...switch (drafts) {
            AsyncData(value: final list) when list.isNotEmpty => [
              Text('Drafts', style: theme.textTheme.titleMedium),
              for (final draft in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_note_rounded),
                  title: Text(
                    draft.title.trim().isEmpty ? 'Untitled match' : draft.title,
                  ),
                  subtitle: Text(
                    draft.startAt == null
                        ? 'No date yet'
                        : Formatters.shortDate(draft.startAt!),
                  ),
                  onTap: () => _open(context, draft),
                  trailing: IconButton(
                    tooltip: 'Delete draft',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      try {
                        await ref
                            .read(matchRepositoryProvider)
                            .deleteDraft(draft.id);
                      } on Object catch (e) {
                        if (context.mounted) showErrorSnackBar(context, e);
                      }
                    },
                  ),
                ),
            ],
            AsyncError(:final error) => [Text(errorMessage(error))],
            _ => const <Widget>[],
          },
        ],
      ),
    );
  }
}
