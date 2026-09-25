/// Every route path in one place. Navigate with these constants, never with
/// string literals scattered through widgets.
abstract final class AppRoutes {
  static const splash = '/splash';

  static const auth = '/auth';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';

  static const onboarding = '/onboarding';

  static const home = '/home';
  static const discover = '/discover';
  static const messages = '/messages';
  static const profile = '/profile';

  /// Full-screen flow pushed above the tab shell.
  static const createMatch = '/matches/create';
}
