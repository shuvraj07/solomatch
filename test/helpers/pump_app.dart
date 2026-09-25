import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/app.dart';
import 'package:solomatch/features/auth/data/auth_providers.dart';
import 'package:solomatch/features/match_report/data/match_report_providers.dart';
import 'package:solomatch/features/match_requests/data/match_request_providers.dart';
import 'package:solomatch/features/matches/data/match_providers.dart';
import 'package:solomatch/features/my_matches/data/my_matches_providers.dart';
import 'package:solomatch/features/profile/data/profile_providers.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_match_report_repository.dart';
import '../fakes/fake_match_repository.dart';
import '../fakes/fake_match_request_repository.dart';
import '../fakes/fake_my_matches_repository.dart';
import '../fakes/fake_profile_repository.dart';

/// Pumps the whole app with in-memory repositories on a typical phone
/// screen (360 × 800 logical pixels).
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  FakeProfileRepository? profiles,
  FakeMatchRepository? matches,
  FakeMatchRequestRepository? requests,
  FakeMatchReportRepository? reports,
  FakeMyMatchesRepository? myMatches,
}) async {
  final matchRepo = matches ?? FakeMatchRepository();
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(
          profiles ?? FakeProfileRepository(),
        ),
        matchRepositoryProvider.overrideWithValue(matchRepo),
        matchRequestRepositoryProvider.overrideWithValue(
          requests ?? FakeMatchRequestRepository(matchRepo),
        ),
        matchReportRepositoryProvider.overrideWithValue(
          reports ?? FakeMatchReportRepository(matchRepo),
        ),
        myMatchesRepositoryProvider.overrideWithValue(
          myMatches ?? FakeMyMatchesRepository(),
        ),
      ],
      child: const SoloMatchApp(),
    ),
  );
  await tester.pumpAndSettle();
}

extension WidgetTesterActions on WidgetTester {
  /// Scrolls [finder] into view, taps it, and settles.
  Future<void> tapVisible(Finder finder) async {
    // Lazily built lists don't create off-screen items; scroll to them.
    if (finder.evaluate().isEmpty) {
      await scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await ensureVisible(finder);
    await pumpAndSettle();
    await tap(finder);
    await pumpAndSettle();
  }
}
