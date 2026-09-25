import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/app/router/session_redirect.dart';
import 'package:solomatch/app/session/session_state.dart';
import 'package:solomatch/features/venues/domain/venue_models.dart';

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

  test('players cannot open the owner app', () {
    expect(sessionRedirect(ready, AppRoutes.owner), AppRoutes.home);
    expect(sessionRedirect(ready, AppRoutes.ownerEditVenue), AppRoutes.home);
    expect(sessionRedirect(ready, AppRoutes.venues), isNull);
  });

  test('venue owners stay in the owner app, settings and inbox', () {
    const owner = AsyncData<SessionState>(
      OwnerReady(
        testUser,
        OwnerProfile(uid: 'raj', name: 'Raj', phone: '9800000000'),
      ),
    );
    expect(sessionRedirect(owner, AppRoutes.signIn), AppRoutes.owner);
    expect(sessionRedirect(owner, AppRoutes.onboarding), AppRoutes.owner);
    expect(sessionRedirect(owner, AppRoutes.home), AppRoutes.owner);
    expect(sessionRedirect(owner, AppRoutes.createMatch), AppRoutes.owner);
    expect(sessionRedirect(owner, AppRoutes.owner), isNull);
    expect(sessionRedirect(owner, AppRoutes.ownerVenue), isNull);
    expect(sessionRedirect(owner, AppRoutes.settings), isNull);
    expect(sessionRedirect(owner, AppRoutes.notifications), isNull);
  });
}
