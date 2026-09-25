import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/features/match_report/domain/match_report.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/data/firestore_match_repository.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/profile/domain/player_stats.dart';
import 'package:solomatch/shared/models/position_group.dart';
import 'package:solomatch/shared/models/user_summary.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_report_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/seed_match.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

final amit = testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki');
final sita = testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai');

/// A completed match (organizer raj) with Amit and Sita on the roster.
FootballMatch playedMatch({MatchReport? report, MotmResult? motm}) =>
    testMatch(currentPlayers: 2, status: MatchStatus.completed).copyWith(
      votingClosesAt: DateTime.now().add(const Duration(hours: 20)),
      report: report,
      motm: motm,
    );

void main() {
  group('PlayerMatchLine', () {
    test('summary shows goals, assists and cards', () {
      const line = PlayerMatchLine(
        goals: 2,
        assists: 1,
        yellowCards: 2,
        redCard: true,
      );
      expect(line.summary, '⚽2 🅰️1 🟨 🟨 🟥');
      expect(line.isEmpty, isFalse);
      expect(const PlayerMatchLine().isEmpty, isTrue);
      expect(const PlayerMatchLine().summary, '');
    });

    test('post-match window: completed, before deadline, not yet decided', () {
      final now = DateTime.now();
      expect(playedMatch().isPostMatchOpen(now), isTrue);
      expect(
        playedMatch().isPostMatchOpen(now.add(const Duration(days: 2))),
        isFalse,
      );
      expect(
        playedMatch(motm: const MotmResult()).isPostMatchOpen(now),
        isFalse,
      );
      expect(testMatch().isPostMatchOpen(now), isFalse);
    });
  });

  test('match mapper reads report, MOTM and voting deadline', () async {
    final db = FakeFirebaseFirestore();
    final repo = FirestoreMatchRepository(db, _MockStorage(), _MockFunctions());
    await seedMatch(db, completeDraft(id: 'm1'), testOrganizer);
    await db.doc('matches/m1').update({
      'status': 'completed',
      'votingClosesAt': DateTime(2026, 9, 29, 20),
      'report': {
        'players': {
          'amit': {
            'goals': 2,
            'assists': 0,
            'yellowCards': 1,
            'redCard': false,
          },
        },
      },
      'motm': {
        'votes': 3,
        'totalVotes': 5,
        'winners': [
          {
            'uid': 'amit',
            'name': 'Amit Karki',
            'username': 'amit',
            'photoUrl': null,
          },
        ],
      },
    });

    final m = await repo
        .watchMatch('m1')
        .firstWhere((m) => m?.status == MatchStatus.completed);
    expect(m!.votingClosesAt, DateTime(2026, 9, 29, 20));
    expect(
      m.report!.lineFor('amit'),
      const PlayerMatchLine(goals: 2, yellowCards: 1),
    );
    expect(m.report!.lineFor('nobody'), const PlayerMatchLine());
    expect(m.motm!.winners.single.name, 'Amit Karki');
    expect(m.motm!.votes, 3);
  });

  group('after the match', () {
    late FakeMatchRepository matches;
    late FakeMatchRequestRepository requests;
    late FakeMatchReportRepository reports;

    void setUpMatch(FootballMatch m) {
      matches = FakeMatchRepository(matches: [m]);
      requests = FakeMatchRequestRepository(matches)
        ..seedRoster('m1', [
          RosterEntry(
            player: MatchRequestMapper.cardFromProfile(amit),
            group: PositionGroup.mid,
          ),
          RosterEntry(
            player: MatchRequestMapper.cardFromProfile(sita),
            group: PositionGroup.gk,
          ),
        ]);
      reports = FakeMatchReportRepository(matches);
    }

    Future<void> pumpAs(WidgetTester tester, String uid) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser.copyWith(uid: uid)),
        profiles: FakeProfileRepository(
          profiles: [
            testProfile(),
            amit,
            sita,
            testProfile(uid: 'outsider', username: 'outsider'),
          ],
        ),
        matches: matches,
        requests: requests,
        reports: reports,
      );
      // Completed matches aren't on Home; open the details route directly.
      unawaited(
        GoRouter.of(tester.element(find.byType(Scaffold).first))
            .push(AppRoutes.matchDetails('m1')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('organizer records goals and cards; roster shows them', (
      tester,
    ) async {
      setUpMatch(playedMatch());
      await pumpAs(tester, 'raj');

      await tester.tapVisible(find.byKey(const Key('editReportButton')));
      expect(find.text('Match report'), findsOneWidget);

      await tester.tapVisible(
        find.descendant(
          of: find.byKey(const Key('goals_amit')),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.tapVisible(
        find.descendant(
          of: find.byKey(const Key('goals_amit')),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.tapVisible(
        find.descendant(
          of: find.byKey(const Key('yellow_sita')),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.tapVisible(find.byKey(const Key('saveReportButton')));

      expect(reports.savedReports['m1'], {
        'amit': const PlayerMatchLine(goals: 2),
        'sita': const PlayerMatchLine(yellowCards: 1),
      });
      // Back on details, lines appear next to names.
      expect(
        tester.widget<Text>(find.byKey(const Key('rosterLine_amit'))).data,
        '⚽2  CM',
      );
      expect(find.text('Edit match report'), findsOneWidget);
    });

    testWidgets('a player votes for a teammate (not themselves)', (
      tester,
    ) async {
      setUpMatch(playedMatch());
      await pumpAs(tester, 'amit');

      expect(find.text('🏆 Vote Man of the Match'), findsOneWidget);
      expect(find.byKey(const Key('motmNominee_amit')), findsNothing);
      await tester.tapVisible(find.byKey(const Key('motmNominee_sita')));

      expect(reports.votes['m1/amit'], 'sita');
      expect(find.text('Vote saved for Sita Rai'), findsOneWidget);
      expect(find.byKey(const Key('editReportButton')), findsNothing);
    });

    testWidgets('someone who was not there cannot vote', (tester) async {
      setUpMatch(playedMatch());
      await pumpAs(tester, 'outsider');
      expect(
        find.text('🏆 Man of the Match voting is open for players.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('motmNominee_sita')), findsNothing);
    });

    testWidgets('decided MOTM is shown to everyone, including joint winners', (
      tester,
    ) async {
      setUpMatch(
        playedMatch(
          motm: const MotmResult(
            votes: 2,
            totalVotes: 4,
            winners: [
              UserSummary(uid: 'amit', name: 'Amit Karki', username: 'amit'),
              UserSummary(uid: 'sita', name: 'Sita Rai', username: 'sita'),
            ],
          ),
        ),
      );
      await pumpAs(tester, 'outsider');
      expect(find.text('🏆 Joint Men of the Match'), findsOneWidget);
      expect(find.byKey(const Key('motmWinner_amit')), findsOneWidget);
      expect(find.byKey(const Key('motmWinner_sita')), findsOneWidget);
      expect(find.text('2 of 4 votes'), findsNWidgets(2));
    });
  });

  testWidgets('profile shows goals, assists, cards and MOTM awards', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(signedIn: testUser),
      profiles: FakeProfileRepository(
        profiles: [
          testProfile().copyWith(
            stats: const PlayerStats(
              gamesPlayed: 28,
              goals: 14,
              assists: 9,
              yellowCards: 3,
              redCards: 1,
              motmAwards: 4,
            ),
          ),
        ],
      ),
    );
    await tester.tapVisible(find.bySemanticsLabel('Profile'));

    expect(find.text('28'), findsOneWidget);
    expect(find.text('⚽ 14'), findsOneWidget);
    expect(find.text('🅰️ 9'), findsOneWidget);
    expect(find.text('🏆 4'), findsOneWidget);
    expect(find.text('🟨 3'), findsOneWidget);
    expect(find.text('🟥 1'), findsOneWidget);
  });
}
