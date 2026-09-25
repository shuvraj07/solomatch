import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/profile/data/profile_providers.dart';
import '../../features/profile/domain/player_profile.dart';
import '../../features/venues/data/venue_providers.dart';
import '../../features/venues/domain/venue_models.dart';
import 'session_state.dart';

/// Combines the auth state with the user's player profile or venue owner
/// profile. All are realtime, so finishing setup or signing out elsewhere
/// updates this without any manual refresh.
final sessionProvider = Provider<AsyncValue<SessionState>>((ref) {
  final auth = ref.watch(authStateProvider);
  return switch (auth) {
    AsyncData(value: null) => const AsyncData(SignedOut()),
    AsyncData(value: final user?) => _signedIn(ref, user),
    AsyncError(:final error, :final stackTrace) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

AsyncValue<SessionState> _signedIn(Ref ref, AuthUser user) {
  final player = ref.watch(playerProfileProvider(user.uid));
  final owner = ref.watch(ownerProfileProvider(user.uid));
  // An account is one or the other (enforced by security rules).
  if (player case AsyncData(value: final p?)) return AsyncData(Ready(user, p));
  if (owner case AsyncData(value: final o?)) {
    return AsyncData(OwnerReady(user, o));
  }
  for (final v in [player, owner]) {
    if (v case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  if (player.hasValue && owner.hasValue) return AsyncData(NeedsProfile(user));
  return const AsyncLoading();
}

/// Profile of the signed-in player. Only valid inside the player app, where
/// the router guarantees the session is [Ready].
final currentProfileProvider = Provider<PlayerProfile?>((ref) {
  final session = ref.watch(sessionProvider).value;
  return session is Ready ? session.profile : null;
});

/// The signed-in venue owner, inside the owner app.
final currentOwnerProvider = Provider<OwnerProfile?>((ref) {
  final session = ref.watch(sessionProvider).value;
  return session is OwnerReady ? session.owner : null;
});

/// uid of the signed-in player or venue owner (null during setup).
final currentUidProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionProvider).value;
  return session is InApp ? session.user.uid : null;
});
