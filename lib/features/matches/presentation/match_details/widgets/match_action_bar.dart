import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../domain/match_action.dart';

/// Bottom bar with the viewer's main action on a match.
class MatchActionBar extends StatelessWidget {
  const MatchActionBar({
    super.key,
    required this.action,
    required this.pendingRequests,
    required this.onRequestToJoin,
    required this.onWithdraw,
    required this.onLeave,
    required this.onManageRequests,
  });

  final MatchAction action;

  /// Pending request count, shown to the organizer.
  final int pendingRequests;
  final VoidCallback onRequestToJoin;
  final VoidCallback onWithdraw;
  final VoidCallback onLeave;
  final VoidCallback onManageRequests;

  @override
  Widget build(BuildContext context) {
    Widget disabled(String label) =>
        FilledButton(onPressed: null, child: Text(label));

    final (Widget main, Widget? secondary) = switch (action) {
      MatchAction.requestToJoin => (
        FilledButton(
          key: const Key('requestToJoinButton'),
          onPressed: onRequestToJoin,
          child: const Text('Request to Join'),
        ),
        null,
      ),
      MatchAction.pending => (
        const FilledButton.tonal(
          key: Key('requestPendingButton'),
          onPressed: null,
          child: Text('Request Pending ⏳'),
        ),
        TextButton(
          key: const Key('withdrawButton'),
          onPressed: onWithdraw,
          child: const Text('Withdraw request'),
        ),
      ),
      MatchAction.playing => (
        const FilledButton.tonal(
          key: Key('playingButton'),
          onPressed: null,
          child: Text("You're Playing ⚽"),
        ),
        TextButton(
          key: const Key('leaveButton'),
          onPressed: onLeave,
          child: const Text('Leave match'),
        ),
      ),
      MatchAction.organizer => (
        FilledButton.icon(
          key: const Key('manageRequestsButton'),
          onPressed: onManageRequests,
          icon: Badge(
            isLabelVisible: pendingRequests > 0,
            label: Text('$pendingRequests'),
            child: const Icon(Icons.group_add_rounded),
          ),
          label: const Text('Player requests'),
        ),
        null,
      ),
      MatchAction.declined => (disabled('Request declined'), null),
      MatchAction.full => (disabled('Match Full'), null),
      MatchAction.cancelled => (disabled('Match cancelled'), null),
      MatchAction.started => (disabled('Match in progress'), null),
      MatchAction.completed => (disabled('Match played'), null),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [main, ?secondary],
        ),
      ),
    );
  }
}
