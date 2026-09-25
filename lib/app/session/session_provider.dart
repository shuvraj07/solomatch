import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/profile/data/profile_providers.dart';
import '../../features/profile/domain/player_profile.dart';
import 'session_state.dart';

/// Combines the auth state with the user's profile document. Both are
/// realtime, so finishing onboarding or signing out elsewhere updates this
/// without any manual refresh.
final sessionProvider = Provider<AsyncValue<SessionState>>((ref) {
  final auth = ref.watch(authStateProvider);
  return switch (auth) {
    AsyncData(value: null) => const AsyncData(SignedOut()),
    AsyncData(value: final user?) =>
      ref
          .watch(playerProfileProvider(user.uid))
          .whenData(
            (profile) =>
                profile == null ? NeedsProfile(user) : Ready(user, profile),
          ),
    AsyncError(:final error, :final stackTrace) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

/// Profile of the signed-in player. Only valid inside the main app, where
/// the router guarantees the session is [Ready].
final currentProfileProvider = Provider<PlayerProfile?>((ref) {
  final session = ref.watch(sessionProvider).value;
  return session is Ready ? session.profile : null;
});
