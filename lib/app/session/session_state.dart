import '../../features/auth/domain/auth_user.dart';
import '../../features/profile/domain/player_profile.dart';
import '../../features/venues/domain/venue_models.dart';

/// Where the current user is in the sign-in → setup → app journey.
sealed class SessionState {
  const SessionState();
}

final class SignedOut extends SessionState {
  const SignedOut();
}

/// Signed in but has not set up a player profile or a venue yet.
final class NeedsProfile extends SessionState {
  const NeedsProfile(this.user);

  final AuthUser user;
}

/// Signed in and set up, as a player or a venue owner.
sealed class InApp extends SessionState {
  const InApp(this.user);

  final AuthUser user;
}

/// A player: the main app (Home, Discover, Messages, Profile).
final class Ready extends InApp {
  const Ready(super.user, this.profile);

  final PlayerProfile profile;
}

/// A venue owner: the owner app (Schedule, Venue, Account).
final class OwnerReady extends InApp {
  const OwnerReady(super.user, this.owner);

  final OwnerProfile owner;
}
