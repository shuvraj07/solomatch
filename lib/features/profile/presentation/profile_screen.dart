import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/session/sign_out.dart';
import 'widgets/player_profile_view.dart';

/// The signed-in player's own profile. Full editing, reviews and settings
/// arrive in later phases.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            key: const Key('signOutButton'),
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(signOutProvider)(),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : PlayerProfileView(
              profile: profile,
              actions: [
                FilledButton.tonalIcon(
                  key: const Key('myMatchesButton'),
                  onPressed: () => context.push(AppRoutes.myMatches),
                  icon: const Icon(Icons.event_note_rounded),
                  label: const Text('My matches'),
                ),
              ],
            ),
    );
  }
}
