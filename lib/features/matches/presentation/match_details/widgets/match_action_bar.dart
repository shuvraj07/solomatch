import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../domain/match_action.dart';

/// Bottom bar with the viewer's main action on a match.
class MatchActionBar extends StatelessWidget {
  const MatchActionBar({
    super.key,
    required this.action,
    required this.onRequestToJoin,
  });

  final MatchAction action;
  final VoidCallback onRequestToJoin;

  @override
  Widget build(BuildContext context) {
    final button = switch (action) {
      MatchAction.requestToJoin => FilledButton(
        key: const Key('requestToJoinButton'),
        onPressed: onRequestToJoin,
        child: const Text('Request to Join'),
      ),
      MatchAction.organizer => const FilledButton.tonal(
        onPressed: null,
        child: Text("You're organizing this match"),
      ),
      MatchAction.full => const FilledButton(
        onPressed: null,
        child: Text('Match Full'),
      ),
      MatchAction.cancelled => const FilledButton(
        onPressed: null,
        child: Text('Match cancelled'),
      ),
      MatchAction.started => const FilledButton(
        onPressed: null,
        child: Text('Match in progress'),
      ),
      MatchAction.completed => const FilledButton(
        onPressed: null,
        child: Text('Match played'),
      ),
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: button,
      ),
    );
  }
}
