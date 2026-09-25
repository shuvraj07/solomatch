import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/features/live/domain/live_models.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
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

/// Kicked off 20 minutes ago, 60 minutes long.
FootballMatch liveMatch({String organizer = 'raj'}) {
  final start = DateTime.now().subtract(const Duration(minutes: 20));
  return testMatch(
    organizerUid: organizer,
    status: MatchStatus.started,
    currentPlayers: 1,
  ).copyWith(startAt: start, endAt: start.add(const Duration(hours: 1)));
}

void main() {
  group('LiveMatch', () {
    final m = testMatch().copyWith(
      startAt: DateTime(2026, 9, 28, 18),
      endAt: DateTime(2026, 9, 28, 19),
    );

    test('phase and minute follow the clock', () {
      expect(LiveMatch.phase(m, DateTime(2026, 9, 28, 17)), LivePhase.upcoming);
      expect(LiveMatch.phase(m, DateTime(2026, 9, 28, 18, 5)), LivePhase.live);
      expect(LiveMatch.phase(m, DateTime(2026, 9, 28, 19)), LivePhase.fullTime);
      expect(
        LiveMatch.phase(
          m.copyWith(status: MatchStatus.cancelled),
          DateTime(2026, 9, 28, 18, 5),
        ),
        LivePhase.cancelled,
      );
      expect(LiveMatch.minute(m, DateTime(2026, 9, 28, 18, 0, 30)), 1);
      expect(LiveMatch.minute(m, DateTime(2026, 9, 28, 18, 36)), 37);
      expect(LiveMatch.minute(m, DateTime(2026, 9, 28, 20)), 60);
    });

    test('only the organizer posts, from 10 min before to 3 h after', () {
      expect(
        LiveMatch.canPost(m, 'raj', DateTime(2026, 9, 28, 17, 55)),
        isTrue,
      );
      expect(
        LiveMatch.canPost(m, 'raj', DateTime(2026, 9, 28, 17, 40)),
        isFalse,
      );
      expect(
        LiveMatch.canPost(m, 'raj', DateTime(2026, 9, 28, 21, 30)),
        isTrue,
      );
      expect(
        LiveMatch.canPost(m, 'raj', DateTime(2026, 9, 28, 22, 30)),
        isFalse,
      );
      expect(
        LiveMatch.canPost(m, 'amit', DateTime(2026, 9, 28, 18, 5)),
        isFalse,
      );
    });

    test('score and report lines from events', () {
      const events = [
        LiveEvent(
          type: LiveEventType.goal,
          side: TeamSide.home,
          playerUid: 'amit',
          minute: 3,
        ),
        LiveEvent(type: LiveEventType.goal, side: TeamSide.away, minute: 9),
        LiveEvent(
          type: LiveEventType.goal,
          side: TeamSide.home,
          playerUid: 'amit',
          minute: 20,
        ),
        LiveEvent(
          type: LiveEventType.yellow,
          side: TeamSide.away,
          playerUid: 'sita',
          minute: 25,
        ),
        LiveEvent(
          type: LiveEventType.red,
          side: TeamSide.away,
          playerUid: 'sita',
          minute: 30,
        ),
      ];
      final score = LiveMatch.scoreOf(events);
      expect(score, (home: 2, away: 1));
      expect(
        LiveMatch.scoreLine((home: 'Tigers', away: 'Eagles'), score),
        'Tigers 2 – 1 Eagles',
      );
      final lines = LiveMatch.reportLines(events);
      expect(lines['amit']!.goals, 2);
      expect(lines['sita']!.yellowCards, 1);
      expect(lines['sita']!.redCard, isTrue);
    });
  });

  group('live center', () {
    Future<void> openMatch(
      WidgetTester tester, {
      required FootballMatch match,
      required FakeLiveRepository live,
      FakeMatchRepository? matches,
    }) async {
      final repo = matches ?? FakeMatchRepository(matches: [match]);
      final requests = FakeMatchRequestRepository(repo)
        ..seedRoster(match.id, [
          RosterEntry(
            player: MatchRequestMapper.cardFromProfile(amit),
            group: PositionGroup.mid,
          ),
        ]);
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(profiles: [testProfile(), amit]),
        matches: repo,
        requests: requests,
        live: live,
      );
      unawaited(
        GoRouter.of(tester.element(find.byType(Scaffold).first))
            .push(AppRoutes.matchDetails(match.id)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('organizer posts a goal, a card, and undoes', (tester) async {
      final matches = FakeMatchRepository(matches: [liveMatch()]);
      final live = FakeLiveRepository(matches: matches);
      await openMatch(tester, match: liveMatch(), live: live, matches: matches);

      expect(find.text("● LIVE 21'"), findsOneWidget);
      expect(find.text('0 – 0'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('goal_home')));
      await tester.tapVisible(find.byKey(const Key('eventPlayer_amit')));
      await tester.tapVisible(find.byKey(const Key('saveEventButton')));
      expect(find.text('1 – 0'), findsOneWidget);
      expect(find.text('⚽ Amit Karki'), findsOneWidget);
      final goal = live.events['m1']!.single;
      expect(
        (goal.side, goal.playerUid, goal.minute),
        (TeamSide.home, 'amit', 21),
      );

      await tester.tapVisible(find.byKey(const Key('yellowCardButton')));
      await tester.tapVisible(
        find.descendant(
          of: find.byType(SegmentedButton<TeamSide>),
          matching: find.text('Team B'),
        ),
      );
      await tester.tapVisible(find.byKey(const Key('saveEventButton')));
      expect(live.events['m1']!.last.side, TeamSide.away);
      expect(find.text('🟨 Yellow card'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('undoEventButton')));
      await tester.tapVisible(find.byKey(const Key('confirmUndoButton')));
      expect(live.events['m1']!.length, 1);
      expect(find.text('🟨 Yellow card'), findsNothing);
    });

    testWidgets('organizer renames the teams', (tester) async {
      final matches = FakeMatchRepository(matches: [liveMatch()]);
      await openMatch(
        tester,
        match: liveMatch(),
        live: FakeLiveRepository(matches: matches),
        matches: matches,
      );
      await tester.tapVisible(find.byKey(const Key('editTeamsButton')));
      await tester.enterText(find.byKey(const Key('homeTeamField')), 'Tigers');
      await tester.enterText(find.byKey(const Key('awayTeamField')), 'Eagles');
      await tester.tapVisible(find.byKey(const Key('saveTeamsButton')));
      expect(find.text('Tigers'), findsOneWidget);
      expect(find.text('Eagles'), findsOneWidget);
      expect(matches.matchOf('m1')!.teams, (home: 'Tigers', away: 'Eagles'));
    });

    testWidgets('anyone can watch and follow; only the organizer posts', (
      tester,
    ) async {
      final match = liveMatch(organizer: 'sita').copyWith(followerCount: 11);
      final live = FakeLiveRepository()
        ..events['m1'] = [
          const LiveEvent(
            id: 'e1',
            type: LiveEventType.goal,
            side: TeamSide.away,
            playerName: 'Sita Rai',
            minute: 7,
          ),
        ];
      await openMatch(tester, match: match, live: live);

      expect(find.text('0 – 1'), findsOneWidget);
      expect(find.text('⚽ Sita Rai'), findsOneWidget);
      expect(find.text('👀 11 following'), findsOneWidget);
      expect(find.byKey(const Key('goal_home')), findsNothing);
      expect(find.byKey(const Key('editTeamsButton')), findsNothing);

      await tester.tapVisible(find.byKey(const Key('followMatchButton')));
      expect(live.following, {'m1/raj'});
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('before kick-off: Team A vs Team B, follow, no controls', (
      tester,
    ) async {
      await openMatch(
        tester,
        match: testMatch(organizerUid: 'sita'),
        live: FakeLiveRepository(),
      );
      // Before kick-off it's a compact row below the roster.
      await tester.scrollUntilVisible(
        find.byKey(const Key('liveCenter')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Team A  vs  Team B'), findsOneWidget);
      expect(find.byKey(const Key('followMatchButton')), findsOneWidget);
      expect(find.byKey(const Key('liveMinute')), findsNothing);
    });

    testWidgets('Home "Live now" shows the score', (tester) async {
      final m = liveMatch(organizer: 'sita').copyWith(
        teams: (home: 'Tigers', away: 'Eagles'),
        score: (home: 2, away: 1),
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(profiles: [testProfile()]),
        matches: FakeMatchRepository(matches: [m]),
      );
      expect(find.text("Tigers 2 – 1 Eagles · 21'"), findsOneWidget);
    });
  });
}
