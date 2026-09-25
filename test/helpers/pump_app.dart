import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/app.dart';
import 'package:solomatch/app/providers/clock_provider.dart';
import 'package:solomatch/features/auth/data/auth_providers.dart';
import 'package:solomatch/features/chat/data/chat_providers.dart';
import 'package:solomatch/features/match_report/data/match_report_providers.dart';
import 'package:solomatch/features/match_requests/data/match_request_providers.dart';
import 'package:solomatch/features/matches/data/match_providers.dart';
import 'package:solomatch/features/my_matches/data/my_matches_providers.dart';
import 'package:solomatch/features/notifications/data/notification_providers.dart';
import 'package:solomatch/features/profile/data/profile_providers.dart';
import 'package:solomatch/features/reviews/data/review_providers.dart';
import 'package:solomatch/features/safety/data/safety_providers.dart';
import 'package:solomatch/features/settings/data/settings_providers.dart';
import 'package:solomatch/features/venues/data/venue_providers.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_chat_repository.dart';
import '../fakes/fake_match_report_repository.dart';
import '../fakes/fake_match_repository.dart';
import '../fakes/fake_match_request_repository.dart';
import '../fakes/fake_my_matches_repository.dart';
import '../fakes/fake_notifications.dart';
import '../fakes/fake_profile_repository.dart';
import '../fakes/fake_review_repository.dart';
import '../fakes/fake_settings_safety.dart';
import '../fakes/fake_venue_repository.dart';

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
  FakeNotificationRepository? notifications,
  FakePushMessaging? push,
  FakeChatRepository? chat,
  FakeReviewRepository? reviews,
  FakeSettingsRepository? settings,
  FakeSafetyRepository? safety,
  FakeVenueRepository? venues,
  DateTime? now,
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
        notificationRepositoryProvider.overrideWithValue(
          notifications ?? FakeNotificationRepository(),
        ),
        pushMessagingProvider.overrideWithValue(push ?? FakePushMessaging()),
        chatRepositoryProvider.overrideWithValue(chat ?? FakeChatRepository()),
        reviewRepositoryProvider.overrideWithValue(
          reviews ?? FakeReviewRepository(),
        ),
        settingsRepositoryProvider.overrideWithValue(
          settings ?? FakeSettingsRepository(),
        ),
        safetyRepositoryProvider.overrideWithValue(
          safety ?? FakeSafetyRepository(),
        ),
        venueRepositoryProvider.overrideWithValue(
          venues ?? FakeVenueRepository(),
        ),
        if (now != null) clockProvider.overrideWithValue(() => now),
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
