import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/session/session_provider.dart';
import 'package:solomatch/features/matches/data/match_mapper.dart';
import 'package:solomatch/features/matches/domain/create_match_step.dart';
import 'package:solomatch/features/matches/domain/lineup_player.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/domain/match_validator.dart';
import 'package:solomatch/features/matches/presentation/create_match/steps/lineup_step.dart';
import 'package:solomatch/features/profile/data/profile_providers.dart';
import 'package:solomatch/shared/models/position.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../../fakes/fake_match_repository.dart';
import '../../../fakes/fake_profile_repository.dart';
import '../../../fakes/match_test_data.dart';
import '../../../fakes/test_data.dart';

const amit = LineupPlayer(
  uid: 'amit',
  name: 'Amit Karki',
  username: 'amit',
  primaryPosition: Position.goalkeeper,
  group: PositionGroup.gk,
);

void main() {
  group('confirmed players', () {
    test('count toward the match; open spots shrink', () {
      final d = completeDraft().copyWith(
        organizerPlaying: true,
        lineup: const [amit],
        guestCount: 3,
      );
      expect(d.confirmedCount, 5);
      expect(d.openSpots, 5);
      expect(
        MatchValidator.validateStep(CreateMatchStep.lineup, d, now: testNow),
        isNull,
      );
    });

    test('cannot confirm more players than places', () {
      final d = completeDraft().copyWith(maxPlayers: 4, guestCount: 5);
      expect(
        MatchValidator.validateStep(CreateMatchStep.lineup, d, now: testNow),
        contains('5 players confirmed'),
      );
    });

    test('saved in the draft with absolute kick-off times', () {
      final d = completeDraft().copyWith(
        organizerPlaying: true,
        organizerGroup: PositionGroup.fwd,
        lineup: const [amit],
        guestCount: 2,
      );
      final doc = MatchMapper.draftTo(d);
      expect(doc['lineup'], [
        {
          'uid': 'amit',
          'name': 'Amit Karki',
          'username': 'amit',
          'photoUrl': null,
          'primaryPosition': 'goalkeeper',
          'group': 'gk',
        },
      ]);
      expect(doc['organizerGroup'], 'fwd');
      expect(doc['guestCount'], 2);
      expect(doc['startAt'], isNotNull);

      // updatedAt is a server-timestamp placeholder until Firestore stores it.
      final back = MatchMapper.draftFromFirestore(
        'd1',
        {...doc}..remove('updatedAt'),
      );
      expect(back.lineup, [amit]);
      expect(back.organizerPlaying, isTrue);
      expect(back.guestCount, 2);
    });

    test('publishing a lineup: the match starts part-filled', () async {
      final repo = FakeMatchRepository();
      await repo.publish(
        completeDraft().copyWith(lineup: const [amit], guestCount: 8),
      );
      final m = repo.matchOf('d1')!;
      expect(m.currentPlayers, 9);
      expect(m.spotsRemaining, 1);
      expect(m.guestCount, 8);
      expect(m.status, MatchStatus.filling);
    });
  });

  testWidgets('Your players step: search, add with position, guests, summary', (
    tester,
  ) async {
    var draft = completeDraft();
    final profiles = FakeProfileRepository(
      profiles: [
        testProfile(),
        testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki'),
        testProfile(uid: 'amir', username: 'amir', fullName: 'Amir Rai'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profiles),
          currentProfileProvider.overrideWithValue(testProfile()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: LineupStep(
                  draft: draft,
                  onChanged: (change) => setState(() => draft = change(draft)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('10 players · 0 already confirmed · 10 still needed'),
      findsOneWidget,
    );

    // I'm playing too.
    await tester.tap(find.byKey(const Key('organizerPlayingSwitch')));
    await tester.pumpAndSettle();
    expect(draft.organizerPlaying, isTrue);
    expect(draft.organizerGroup, PositionGroup.mid); // Raj is a CM

    // Search finds both Amits; I never appear in my own results.
    await tester.enterText(find.byKey(const Key('playerSearchField')), 'am');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('searchResult_amit')), findsOneWidget);
    expect(find.byKey(const Key('searchResult_amir')), findsOneWidget);
    expect(find.byKey(const Key('searchResult_raj')), findsNothing);

    await tester.tap(find.byKey(const Key('searchResult_amit')));
    await tester.pumpAndSettle();
    expect(draft.lineup.single.uid, 'amit');
    expect(find.byKey(const Key('lineup_amit')), findsOneWidget);

    // Put Amit in goal.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('lineup_amit')),
        matching: find.text('🧤 GK'),
      ),
    );
    await tester.pumpAndSettle();
    expect(draft.lineup.single.group, PositionGroup.gk);

    // Two friends without the app.
    for (var i = 0; i < 2; i++) {
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('guestStepper')),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(draft.guestCount, 2);
    expect(
      find.text('10 players · 4 already confirmed · 6 still needed'),
      findsOneWidget,
    );

    // Remove Amit again.
    await tester.tap(find.byTooltip('Remove Amit Karki'));
    await tester.pumpAndSettle();
    expect(draft.lineup, isEmpty);
    expect(draft, isA<MatchDraft>());
  });
}
