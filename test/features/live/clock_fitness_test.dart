import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/app/session/session_provider.dart';
import 'package:solomatch/features/live/domain/live_models.dart';
import 'package:solomatch/features/match_requests/domain/join_request.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/presentation/create_match/steps/lineup_step.dart';
import 'package:solomatch/features/profile/data/profile_providers.dart';
import 'package:solomatch/shared/models/fitness.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_live_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

final amit = testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki');

FootballMatch kickedOff() {
  final start = DateTime.now().subtract(const Duration(minutes: 20));
  return testMatch(status: MatchStatus.started)
      .copyWith(startAt: start, endAt: start.add(const Duration(hours: 1)));
}

Future<void> push(WidgetTester tester, String route) async {
  unawaited(
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('organizer clock', () {
    final t0 = DateTime(2026, 9, 28, 18, 5);
    FootballMatch withClock(ClockPhase phase, int before, DateTime? since) =>
        testMatch().copyWith(
          startAt: DateTime(2026, 9, 28, 18),
          endAt: DateTime(2026, 9, 28, 19),
          clock: (phase: phase, periodStartedAt: since, elapsedBefore: before),
        );

    test('runs from kick-off, pauses at half-time, adds the 2nd half', () {
      final first = withClock(ClockPhase.firstHalf, 0, t0);
      expect(
        LiveMatch.clockText(
          first,
          t0.add(const Duration(minutes: 12, seconds: 7)),
        ),
        '12:07',
      );
      expect(LiveMatch.minute(first, t0.add(const Duration(minutes: 12))), 13);

      final half = withClock(ClockPhase.halfTime, 30 * 60, null);
      // Paused: the time doesn't move.
      expect(
        LiveMatch.clockText(half, t0.add(const Duration(hours: 5))),
        '30:00',
      );
      expect(LiveMatch.phase(half, t0), LivePhase.live);

      final second = withClock(ClockPhase.secondHalf, 30 * 60, t0);
      expect(
        LiveMatch.clockText(second, t0.add(const Duration(minutes: 5))),
        '35:00',
      );
      // Past the scheduled end with the clock still running: still live.
      expect(
        LiveMatch.phase(second, DateTime(2026, 9, 28, 19, 10)),
        LivePhase.live,
      );

      final ft = withClock(ClockPhase.fullTime, 62 * 60, null);
      expect(LiveMatch.phase(ft, t0), LivePhase.fullTime);
    });

    testWidgets('kick off → half-time → 2nd half → full time', (tester) async {
      final matches = FakeMatchRepository(matches: [kickedOff()]);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(profiles: [testProfile()]),
        matches: matches,
        live: FakeLiveRepository(matches: matches),
      );
      await push(tester, AppRoutes.matchDetails('m1'));

      // Before the whistle it follows the schedule.
      expect(find.text("● LIVE 21'"), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('clock_kickoff')));
      expect(matches.matchOf('m1')!.clock?.phase, ClockPhase.firstHalf);
      expect(find.text('● LIVE 00:00'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('clock_halftime')));
      expect(matches.matchOf('m1')!.clock?.phase, ClockPhase.halfTime);
      expect(find.textContaining('HALF-TIME'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('clock_secondhalf')));
      expect(find.textContaining('2nd half'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('clock_fulltime')));
      await tester.tapVisible(find.byKey(const Key('confirmFullTimeButton')));
      expect(matches.matchOf('m1')!.clock?.phase, ClockPhase.fullTime);
    });
  });

  group('fitness', () {
    testWidgets('player sets themselves injured, then fit', (tester) async {
      final profiles = FakeProfileRepository(profiles: [testProfile()]);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: profiles,
      );
      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      await tester.tapVisible(find.byKey(const Key('fitness_injured')));
      expect(profiles.profileOf('raj')!.fitness, Fitness.injured);
      await tester.tapVisible(find.byKey(const Key('fitness_fit')));
      expect(profiles.profileOf('raj')!.fitness, Fitness.fit);
    });

    testWidgets('others see the injury on the profile', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(
          profiles: [
            testProfile(),
            amit.copyWith(fitness: Fitness.injured),
          ],
        ),
      );
      await push(tester, AppRoutes.playerProfile('amit'));
      expect(find.text('🚑 Injured'), findsOneWidget);
      expect(find.byKey(const Key('fitnessPicker')), findsNothing);
    });

    testWidgets('an injured player cannot ask to join', (tester) async {
      final matches = FakeMatchRepository(
        matches: [testMatch(organizerUid: 'sita')],
      );
      final requests = FakeMatchRequestRepository(matches);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(
          profiles: [testProfile().copyWith(fitness: Fitness.injured)],
        ),
        matches: matches,
        requests: requests,
      );
      await push(tester, AppRoutes.matchDetails('m1'));
      await tester.tapVisible(find.byKey(const Key('requestToJoinButton')));
      expect(find.textContaining('You’re marked injured'), findsOneWidget);
      expect(find.byKey(const Key('sendRequestButton')), findsNothing);
      expect(requests.requestOf('m1', 'raj'), isNull);
    });

    testWidgets('organizer cannot accept an injured player', (tester) async {
      final matches = FakeMatchRepository(matches: [testMatch()]);
      final requests = FakeMatchRequestRepository(matches);
      final profiles = FakeProfileRepository(
        profiles: [
          testProfile(),
          amit.copyWith(fitness: Fitness.injured),
        ],
      );
      await requests.requestToJoin(
        match: testMatch(),
        player: amit,
        preferredGroup: PositionGroup.mid,
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: profiles,
        matches: matches,
        requests: requests,
      );
      await push(tester, AppRoutes.matchRequests('m1'));

      expect(find.byKey(const Key('fitness_amit')), findsOneWidget);
      final accept = find.byKey(const Key('accept_amit'));
      await tester.ensureVisible(accept);
      expect(tester.widget<ButtonStyleButton>(accept).onPressed, isNull);
      await tester.tap(accept, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(requests.requestOf('m1', 'amit')!.status, RequestStatus.pending);
    });

    testWidgets('injured players cannot be added to the lineup', (
      tester,
    ) async {
      var draft = completeDraft();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(
              FakeProfileRepository(
                profiles: [
                  testProfile(),
                  amit.copyWith(fitness: Fitness.injured),
                ],
              ),
            ),
            currentProfileProvider.overrideWithValue(testProfile()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: LineupStep(
                    draft: draft,
                    onChanged: (change) =>
                        setState(() => draft = change(draft)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('playerSearchField')),
        'amit',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      final result = find.byKey(const Key('searchResult_amit'));
      expect(find.textContaining('🚑 Injured'), findsOneWidget);
      expect(tester.widget<ListTile>(result).enabled, isFalse);
      await tester.tap(result, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(draft.lineup, isEmpty);
    });
  });
}
