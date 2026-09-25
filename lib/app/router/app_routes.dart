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

  static const myMatches = '/my-matches';

  static const notifications = '/notifications';

  static const chatPattern = '/chat/:conversationId';
  static String chat(String conversationId) => '/chat/$conversationId';

  static const playerProfilePattern = '/players/:uid';
  static String playerProfile(String uid) => '/players/$uid';

  /// Full-screen flows pushed above the tab shell.
  static const createMatch = '/matches/create';

  /// The step-by-step flow; pass the MatchDraft as `extra`.
  static const createMatchFlow = '/matches/create/edit';

  static const matchDetailsPattern = '/matches/:matchId';
  static String matchDetails(String matchId) => '/matches/$matchId';

  static const matchRequestsPattern = '/matches/:matchId/requests';
  static String matchRequests(String matchId) => '/matches/$matchId/requests';

  static const matchReportPattern = '/matches/:matchId/report';
  static String matchReport(String matchId) => '/matches/$matchId/report';
}
