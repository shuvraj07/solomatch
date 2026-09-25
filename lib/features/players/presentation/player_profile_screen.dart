import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../profile/data/profile_providers.dart';
import '../../profile/presentation/widgets/player_profile_view.dart';
import '../../safety/data/safety_providers.dart';
import '../../safety/domain/safety_repository.dart';
import '../../safety/presentation/report_sheet.dart';

/// Another player's public football profile. Live: stats update as matches
/// are completed, reported and awarded.
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider(uid));
    final me = ref.watch(currentProfileProvider)?.uid;
    final blocked = ref.watch(blockedIdsProvider).contains(uid);
    final name = profile.value?.fullName ?? 'this player';

    Future<void> toggleBlock() async {
      if (me == null) return;
      final repo = ref.read(safetyRepositoryProvider);
      if (blocked) {
        await runWithFeedback(
          context,
          () => repo.unblock(me, uid),
          success: '$name unblocked',
        );
        return;
      }
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Block $name?'),
          content: const Text(
            'They won’t be able to request your matches, and you won’t '
            'be able to message each other. Their messages are hidden '
            'from you in group chats. They aren’t told.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirmBlockButton'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Block'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      await runWithFeedback(
        context,
        () => repo.block(me, (uid: uid, name: name)),
        success: '$name blocked',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
        actions: [
          if (me != null && me != uid)
            PopupMenuButton<String>(
              key: const Key('playerMenu'),
              onSelected: (value) => value == 'report'
                  ? showReportSheet(
                      context,
                      type: ReportTarget.player,
                      targetId: uid,
                      targetName: name,
                    )
                  : toggleBlock(),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Report player'),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Text(blocked ? 'Unblock' : 'Block'),
                ),
              ],
            ),
        ],
      ),
      body: switch (profile) {
        AsyncData(value: final p?) => PlayerProfileView(
          profile: p,
          isMe: p.uid == me,
        ),
        AsyncData() => const PlaceholderView(
          icon: Icons.person_off_rounded,
          title: 'Player not found',
          message: 'This profile is no longer available.',
        ),
        AsyncError(:final error) => Center(child: Text(errorMessage(error))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
