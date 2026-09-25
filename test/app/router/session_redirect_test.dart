import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/app/router/session_redirect.dart';
import 'package:solomatch/app/session/session_state.dart';

import '../../fakes/test_data.dart';

void main() {
  const loading = AsyncLoading<SessionState>();
  const signedOut = AsyncData<SessionState>(SignedOut());
  const needsProfile = AsyncData<SessionState>(NeedsProfile(testUser));
  final ready = AsyncData<SessionState>(Ready(testUser, testProfile()));

  test('loading or error goes to splash', () {
    expect(sessionRedirect(loading, AppRoutes.home), AppRoutes.splash);
    expect(sessionRedirect(loading, AppRoutes.splash), isNull);
    expect(
      sessionRedirect(AsyncError(Exception(), StackTrace.empty), '/home'),
      AppRoutes.splash,
    );
  });

  test('signed out is kept inside auth screens', () {
    expect(sessionRedirect(signedOut, AppRoutes.home), AppRoutes.signIn);
    expect(sessionRedirect(signedOut, AppRoutes.splash), AppRoutes.signIn);
    expect(sessionRedirect(signedOut, AppRoutes.onboarding), AppRoutes.signIn);
    expect(sessionRedirect(signedOut, AppRoutes.signUp), isNull);
    expect(sessionRedirect(signedOut, AppRoutes.forgotPassword), isNull);
  });

  test('new user must finish onboarding', () {
    expect(sessionRedirect(needsProfile, AppRoutes.home), AppRoutes.onboarding);
    expect(
      sessionRedirect(needsProfile, AppRoutes.signIn),
      AppRoutes.onboarding,
    );
    expect(sessionRedirect(needsProfile, AppRoutes.onboarding), isNull);
  });

  test('ready user leaves auth/onboarding and can go anywhere else', () {
    expect(sessionRedirect(ready, AppRoutes.signIn), AppRoutes.home);
    expect(sessionRedirect(ready, AppRoutes.onboarding), AppRoutes.home);
    expect(sessionRedirect(ready, AppRoutes.splash), AppRoutes.home);
    expect(sessionRedirect(ready, AppRoutes.discover), isNull);
    expect(sessionRedirect(ready, AppRoutes.createMatch), isNull);
  });
}
