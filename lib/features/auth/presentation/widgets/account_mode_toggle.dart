import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/session/account_mode.dart';
import '../../../../app/theme/app_spacing.dart';

/// "Player | Venue owner" switch on the sign-in and sign-up screens.
class AccountModeToggle extends ConsumerWidget {
  const AccountModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(accountModeProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: SegmentedButton<AccountMode>(
        segments: const [
          ButtonSegment(
            value: AccountMode.player,
            label: Text('Player', key: Key('accountMode_player')),
            icon: Icon(Icons.sports_soccer_rounded),
          ),
          ButtonSegment(
            value: AccountMode.owner,
            label: Text('Venue owner', key: Key('accountMode_owner')),
            icon: Icon(Icons.stadium_rounded),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(accountModeProvider.notifier).select(s.first),
      ),
    );
  }
}
