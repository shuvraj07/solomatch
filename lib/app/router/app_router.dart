import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/chat/presentation/messages_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/match_report/presentation/match_report_screen.dart';
import '../../features/match_requests/presentation/match_requests_screen.dart';
import '../../features/matches/domain/match_draft.dart';
import '../../features/matches/presentation/create_match/create_match_flow_screen.dart';
import '../../features/matches/presentation/create_match/create_match_screen.dart';
import '../../features/matches/presentation/match_details/match_details_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../session/session_provider.dart';
import '../session/splash_screen.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';
import 'session_redirect.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // The router is built once; session changes only re-run the redirect.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        sessionRedirect(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createMatch,
        builder: (context, state) => const CreateMatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.createMatchFlow,
        // The draft travels as `extra`; without one (e.g. after a restart)
        // fall back to the draft picker.
        redirect: (context, state) =>
            state.extra is MatchDraft ? null : AppRoutes.createMatch,
        builder: (context, state) =>
            CreateMatchFlowScreen(initialDraft: state.extra! as MatchDraft),
      ),
      GoRoute(
        path: AppRoutes.matchDetailsPattern,
        builder: (context, state) =>
            MatchDetailsScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.matchRequestsPattern,
        builder: (context, state) =>
            MatchRequestsScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.matchReportPattern,
        builder: (context, state) =>
            MatchReportScreen(matchId: state.pathParameters['matchId']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
