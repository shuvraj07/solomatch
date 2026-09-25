import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_state.dart';
import 'app_routes.dart';

/// Decides where the user must be for the current session, or null to stay.
///
///  * loading / error        → splash
///  * signed out             → sign-in (auth screens allowed)
///  * signed in, no profile  → onboarding
///  * ready                  → leaves splash/auth/onboarding for home
String? sessionRedirect(AsyncValue<SessionState> session, String location) {
  bool at(String path) => location == path || location.startsWith('$path/');

  final inAuth = at(AppRoutes.auth);
  final atSplash = at(AppRoutes.splash);
  final atOnboarding = at(AppRoutes.onboarding);

  final state = session.value;
  if (state == null || session.hasError) {
    return atSplash ? null : AppRoutes.splash;
  }

  return switch (state) {
    SignedOut() => inAuth ? null : AppRoutes.signIn,
    NeedsProfile() => atOnboarding ? null : AppRoutes.onboarding,
    Ready() => (inAuth || atSplash || atOnboarding) ? AppRoutes.home : null,
  };
}
