import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/profile/domain/player_stats.dart';
import 'package:solomatch/features/reviews/domain/review.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/fake_review_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

final amit = testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki');
final sita = testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai');

/// Played yesterday, organized by Raj, with Amit and Sita on the roster.
FootballMatch played({Duration endedAgo = const Duration(days: 1)}) {
  final end = DateTime.now().subtract(endedAgo);
  return testMatch(
    status: MatchStatus.completed,
    currentPlayers: 2,
  ).copyWith(startAt: end.subtract(const Duration(hours: 2)), endAt: end);
}

final roster = [
  RosterEntry(
    player: MatchRequestMapper.cardFromProfile(amit),
    group: PositionGroup.gk,
  ),
  RosterEntry(
    player: MatchRequestMapper.cardFromProfile(sita),
    group: PositionGroup.mid,
  ),
];

void main() {
  group('ReviewRules', () {
    test('open for 7 days after a played match', () {
      final m = played();
      expect(ReviewRules.isOpen(m, DateTime.now()), isTrue);
      expect(
        ReviewRules.isOpen(
          played(endedAgo: const Duration(days: 8)),
          DateTime.now(),
        ),
        isFalse,
      );
      expect(ReviewRules.isOpen(testMatch(), DateTime.now()), isFalse);
    });

    test('who I can still rate', () {
      final m = played();
      expect(
        ReviewRules.toRate(m, roster, 'amit', const {}),
        unorderedEquals(['raj', 'sita']),
      );
      expect(ReviewRules.toRate(m, roster, 'amit', const {'raj'}), ['sita']);
      expect(ReviewRules.toRate(m, roster, 'stranger', const {}), isEmpty);
    });

    test('deterministic id prevents duplicates', () {
      expect(reviewId('m1', 'amit', 'sita'), 'm1_amit_sita');
    });
  });

  group('screens', () {
    late FakeReviewRepository reviews;
    late FakeMatchRepository matches;
    late FakeMatchRequestRepository requests;

    setUp(() {
      reviews = FakeReviewRepository();
    });

    Future<void> pumpAs(
      WidgetTester tester,
      String uid,
      FootballMatch match,
    ) async {
      matches = FakeMatchRepository(matches: [match]);
      requests = FakeMatchRequestRepository(matches)..seedRoster('m1', roster);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser.copyWith(uid: uid)),
        profiles: FakeProfileRepository(profiles: [testProfile(), amit, sita]),
        matches: matches,
        requests: requests,
        reviews: reviews,
      );
      unawaited(
        GoRouter.of(tester.element(find.byType(Scaffold).first))
            .push(AppRoutes.matchDetails('m1')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a player rates the organizer and a teammate once each', (
      tester,
    ) async {
      await pumpAs(tester, 'amit', played());
      await tester.scrollUntilVisible(
        find.byKey(const Key('rate_raj')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('rateRow_amit')), findsNothing); // not myself
      expect(find.textContaining('0/2 rated'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('rate_raj')));
      await tester.tapVisible(find.byKey(const Key('star_4')));
      expect(find.text('Great'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('reviewCommentField')),
        'Well organized',
      );
      await tester.tapVisible(find.byKey(const Key('submitRatingButton')));

      final r = reviews.all.single;
      expect(r.id, 'm1_amit_raj');
      expect(r.rating, 4);
      expect(r.comment, 'Well organized');
      expect(r.reviewerName, 'Amit Karki');
      expect(find.text('✓ Rated'), findsOneWidget);
      expect(find.byKey(const Key('rate_raj')), findsNothing);
      expect(find.textContaining('1/2 rated'), findsOneWidget);
    });

    testWidgets('no rating card for outsiders or after 7 days', (tester) async {
      await pumpAs(tester, 'stranger', played());
      expect(find.text('⭐ Rate players'), findsNothing);
    });

    testWidgets('rating window closed', (tester) async {
      await pumpAs(tester, 'amit', played(endedAgo: const Duration(days: 8)));
      expect(find.text('⭐ Rate players'), findsNothing);
    });

    testWidgets('profile shows the rating and latest reviews', (tester) async {
      reviews = FakeReviewRepository([
        Review(
          matchId: 'm1',
          reviewerId: 'raj',
          revieweeId: 'amit',
          rating: 5,
          comment: 'Brilliant saves',
          reviewerName: 'Raj Shrestha',
          matchTitle: 'Saturday Night Football',
          createdAt: DateTime(2026, 9, 24),
        ),
      ]);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(
          profiles: [
            testProfile(),
            amit.copyWith(
              stats: const PlayerStats(ratingAvg: 4.5, ratingCount: 2),
            ),
          ],
        ),
        reviews: reviews,
      );
      unawaited(
        GoRouter.of(tester.element(find.byType(Scaffold).first))
            .push(AppRoutes.playerProfile('amit')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('ratingSummary')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('4.5 (2)'), findsOneWidget);
      expect(find.textContaining('"Brilliant saves"'), findsOneWidget);
    });
  });
}
