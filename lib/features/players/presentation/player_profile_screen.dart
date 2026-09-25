import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../profile/data/profile_providers.dart';
import '../../profile/presentation/widgets/player_profile_view.dart';

/// Another player's public football profile. Live: stats update as matches
/// are completed, reported and awarded.
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider(uid));
    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      body: switch (profile) {
        AsyncData(value: final p?) => PlayerProfileView(profile: p),
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
