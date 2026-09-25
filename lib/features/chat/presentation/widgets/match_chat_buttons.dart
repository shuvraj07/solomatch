import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../match_requests/domain/join_request.dart';
import '../../../match_requests/domain/roster_entry.dart';
import '../../../matches/domain/football_match.dart';
import '../../data/chat_providers.dart';
import '../../domain/chat_repository.dart';

/// Chat shortcuts on a match page:
///  * "Group chat" for the organizer and everyone on the roster
///  * "Message organizer" for a player who asked to join (not rejected)
class MatchChatButtons extends ConsumerWidget {
  const MatchChatButtons({
    super.key,
    required this.match,
    required this.roster,
    required this.myRequest,
    required this.viewerUid,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final JoinRequest? myRequest;
  final String viewerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOrganizer = match.isOrganizer(viewerUid);
    final onRoster = roster.any((e) => e.player.uid == viewerUid);
    // The server creates the group chat when the first player joins.
    final hasGroup = roster.any((e) => e.player.uid != match.organizer.uid);
    final canGroup = hasGroup && (isOrganizer || onRoster);
    final canMessageOrganizer =
        !isOrganizer &&
        myRequest != null &&
        myRequest!.status != RequestStatus.rejected;

    if (!canGroup && !canMessageOrganizer) return const SizedBox.shrink();

    Future<void> messageOrganizer() async {
      try {
        final id = await ref
            .read(chatRepositoryProvider)
            .openDirectChat(matchId: match.id, playerId: viewerUid);
        if (context.mounted) await context.push(AppRoutes.chat(id));
      } on Object catch (e) {
        if (context.mounted) showErrorSnackBar(context, e);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (canGroup)
            FilledButton.tonalIcon(
              key: const Key('groupChatButton'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () =>
                  context.push(AppRoutes.chat(groupChatId(match.id))),
              icon: const Icon(Icons.forum_rounded),
              label: const Text('Group chat'),
            ),
          if (canMessageOrganizer)
            OutlinedButton.icon(
              key: const Key('messageOrganizerButton'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: messageOrganizer,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Message organizer'),
            ),
        ],
      ),
    );
  }
}
