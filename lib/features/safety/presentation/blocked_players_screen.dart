import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../data/safety_providers.dart';

class BlockedPlayersScreen extends ConsumerWidget {
  const BlockedPlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentProfileProvider)?.uid;
    final blocked = ref.watch(blockedPlayersProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Blocked players')),
      body: blocked.isEmpty
          ? const PlaceholderView(
              icon: Icons.block_rounded,
              title: 'Nobody blocked',
              message: 'Block someone from their profile if you need to.',
            )
          : ListView(
              children: [
                for (final b in blocked)
                  ListTile(
                    key: Key('blocked_${b.uid}'),
                    leading: const Icon(Icons.person_off_rounded),
                    title: Text(b.name),
                    trailing: TextButton(
                      onPressed: me == null
                          ? null
                          : () => runWithFeedback(
                              context,
                              () => ref
                                  .read(safetyRepositoryProvider)
                                  .unblock(me, b.uid),
                              success: '${b.name} unblocked',
                            ),
                      child: const Text('Unblock'),
                    ),
                  ),
              ],
            ),
    );
  }
}
