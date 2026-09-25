import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/shared/models/match_format.dart';
import 'package:solomatch/shared/models/price.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

void main() {
  // testNow: Friday 25 Sep 2026, 10:00.
  final futsal = testMatch(id: 'futsal', organizerUid: 'sita');
  final sevens = testMatch(id: 'sevens', organizerUid: 'sita').copyWith(
    title: 'Sunday Sevens',
    format: MatchFormat.sevenASide,
    venue: testVenue.copyWith(name: 'Chyasal Ground', city: 'Lalitpur'),
    startAt: DateTime(2026, 9, 27, 7),
    endAt: DateTime(2026, 9, 27, 9),
    price: const Price(amount: 150),
  );

  Future<void> openDiscover(
    WidgetTester tester, {
    List<FootballMatch> matches = const [],
  }) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(signedIn: testUser),
      profiles: FakeProfileRepository(profiles: [testProfile()]),
      matches: FakeMatchRepository(matches: [futsal, sevens, ...matches]),
      now: testNow,
    );
    await tester.tap(find.bySemanticsLabel('Discover'));
    await tester.pumpAndSettle();
  }

  testWidgets('recommended first, with reasons', (tester) async {
    await openDiscover(tester);
    expect(find.text('2 matches'), findsOneWidget);
    // Futsal is in Raj's city and needs a MID, so it ranks first.
    final first = tester.getTopLeft(find.byKey(const Key('discover_futsal')));
    final second = tester.getTopLeft(find.byKey(const Key('discover_sevens')));
    expect(first.dy, lessThan(second.dy));
    expect(
      find.text('✨ Needs a MID · All levels · In Kathmandu'),
      findsOneWidget,
    );
  });

  testWidgets('sort by soonest', (tester) async {
    await openDiscover(tester);
    await tester.tap(find.byKey(const Key('sortMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soonest').last);
    await tester.pumpAndSettle();
    final sevensY = tester.getTopLeft(find.byKey(const Key('discover_sevens')));
    final futsalY = tester.getTopLeft(find.byKey(const Key('discover_futsal')));
    expect(sevensY.dy, lessThan(futsalY.dy));
  });

  testWidgets('search narrows results', (tester) async {
    await openDiscover(tester);
    await tester.enterText(
      find.byKey(const Key('discoverSearchField')),
      'chyasal',
    );
    await tester.pumpAndSettle();
    expect(find.text('1 match'), findsOneWidget);
    expect(find.text('⚽ Sunday Sevens'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('discoverSearchField')),
      'nowhere',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matches found'), findsOneWidget);
  });

  testWidgets('weekend chip', (tester) async {
    await openDiscover(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('date_weekend')),
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('dateChips')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('date_weekend')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date_weekend')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discover_sevens')), findsOneWidget);
    expect(find.byKey(const Key('discover_futsal')), findsNothing);
  });

  testWidgets('filters sheet: format and free only, then reset', (
    tester,
  ) async {
    await openDiscover(tester);
    await tester.tap(find.byKey(const Key('openFiltersButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filterFormat_sevenASide')));
    await tester.pump();
    await tester.tapVisible(find.byKey(const Key('applyFiltersButton')));
    expect(find.text('1 match'), findsOneWidget);
    expect(find.byKey(const Key('discover_sevens')), findsOneWidget);

    await tester.tap(find.byKey(const Key('openFiltersButton')));
    await tester.pumpAndSettle();
    await tester.tapVisible(find.byKey(const Key('freeOnlySwitch')));
    await tester.tapVisible(find.byKey(const Key('applyFiltersButton')));
    expect(find.text('No matches found'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openFiltersButton')));
    await tester.pumpAndSettle();
    await tester.tapVisible(find.byKey(const Key('resetFiltersButton')));
    await tester.tapVisible(find.byKey(const Key('applyFiltersButton')));
    expect(find.text('2 matches'), findsOneWidget);
  });

  testWidgets('full matches hidden by default', (tester) async {
    await openDiscover(
      tester,
      matches: [
        testMatch(
          id: 'full',
          organizerUid: 'sita',
          currentPlayers: 10,
          status: MatchStatus.full,
        ),
      ],
    );
    expect(find.byKey(const Key('discover_full')), findsNothing);
  });

  testWidgets('Home shows live matches above upcoming', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(signedIn: testUser),
      profiles: FakeProfileRepository(profiles: [testProfile()]),
      matches: FakeMatchRepository(
        matches: [
          futsal,
          testMatch(
            id: 'live',
            status: MatchStatus.started,
          ).copyWith(title: 'Friday Morning Kickabout'),
        ],
      ),
    );
    expect(find.byKey(const Key('liveNowHeader')), findsOneWidget);
    expect(find.text('⚽ Friday Morning Kickabout'), findsOneWidget);
    expect(find.text('● LIVE'), findsOneWidget);
    final liveY = tester.getTopLeft(find.text('⚽ Friday Morning Kickabout'));
    final upcomingY = tester.getTopLeft(find.text('Upcoming matches'));
    expect(liveY.dy, lessThan(upcomingY.dy));
  });

  testWidgets('Home hides the live section when nothing is on', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(signedIn: testUser),
      profiles: FakeProfileRepository(profiles: [testProfile()]),
      matches: FakeMatchRepository(matches: [futsal]),
    );
    expect(find.byKey(const Key('liveNowHeader')), findsNothing);
  });
}
