import '../../features/auth/domain/auth_user.dart';
import '../../features/profile/domain/player_profile.dart';

/// Where the current user is in the sign-in → profile setup → app journey.
sealed class SessionState {
  const SessionState();
}

final class SignedOut extends SessionState {
  const SignedOut();
}

/// Signed in but has not completed profile setup.
final class NeedsProfile extends SessionState {
  const NeedsProfile(this.user);

  final AuthUser user;
}

final class Ready extends SessionState {
  const Ready(this.user, this.profile);

  final AuthUser user;
  final PlayerProfile profile;
}
