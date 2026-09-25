import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/router/app_routes.dart';
import 'package:solomatch/features/auth/domain/auth_user.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/features/matches/domain/create_match_step.dart';
import 'package:solomatch/features/matches/domain/football_match.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/presentation/create_match/create_match_controller.dart';
import 'package:solomatch/features/venues/domain/draft_booking.dart';
import 'package:solomatch/features/venues/domain/slot_planner.dart';
import 'package:solomatch/features/venues/domain/venue_models.dart';
import 'package:solomatch/shared/models/match_format.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/fake_venue_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

const hari = OwnerProfile(uid: 'hari', name: 'Hari Thapa', phone: '9800000000');
const dhuku = VenueProfile(
  id: 'hari',
  name: 'Dhuku Futsal',
  address: 'Baneshwor',
  city: 'Kathmandu',
  phone: '9800000000',
  pricePerHour: 2000,
  amenities: {Amenity.parking, Amenity.floodlights},
);

VenueSlot slot(
  String id,
  DateTime start, {
  SlotStatus status = SlotStatus.free,
  SlotBooking? booking,
}) => VenueSlot(
  id: id,
  venueId: 'hari',
  startAt: start,
  endAt: start.add(const Duration(hours: 1)),
  price: 2000,
  status: status,
  booking: booking,
);

void main() {
  group('SlotPlanner', () {
    // testNow: Friday 25 Sep 2026, 10:00.
    test('splits opening hours and skips times already past', () {
      final slots = SlotPlanner.plan(
        SlotPlan(
          firstDay: testNow,
          fromMinutes: 8 * 60,
          toMinutes: 13 * 60,
          price: 1500,
        ),
        now: testNow,
      );
      // 08, 09 and 10 have started; 11 and 12 remain.
      expect(slots.map((s) => s.startAt.hour), [11, 12]);
      expect(slots.first.price, 1500);
      expect(slots.first.endAt.hour, 12);
    });

    test('repeats on chosen weekdays and skips overlaps', () {
      final tomorrow = DateTime(2026, 9, 26); // Saturday
      final slots = SlotPlanner.plan(
        SlotPlan(
          firstDay: tomorrow,
          fromMinutes: 18 * 60,
          toMinutes: 21 * 60,
          lengthMinutes: 90,
          days: 7,
          weekdays: const {DateTime.saturday, DateTime.sunday},
        ),
        now: testNow,
        existing: [slot('x', DateTime(2026, 9, 27, 19))],
      );
      // Sat 18:00 and 19:30; Sun 18:00 overlaps 19:00–20:00 and so does
      // 19:30, so none on Sunday.
      expect(
        slots.map(
          (s) => '${s.startAt.weekday}@${s.startAt.hour}:${s.startAt.minute}',
        ),
        ['6@18:0', '6@19:30'],
      );
    });

    test('rejects impossible plans', () {
      expect(
        () => SlotPlanner.plan(
          SlotPlan(firstDay: testNow, fromMinutes: 600, toMinutes: 630),
          now: testNow,
        ),
        throwsArgumentError,
      );
    });
  });

  group('booking a slot in a draft', () {
    final s = slot('s1', DateTime(2026, 9, 26, 18));

    test('fills venue, day, times and a per-player price', () {
      final d = const MatchDraft(
        id: 'd',
        organizerId: 'raj',
      ).bookSlot(dhuku, s);
      expect(d.booking, (venueId: 'hari', slotId: 's1'));
      expect(d.venue?.name, 'Dhuku Futsal');
      expect(d.venue?.venueId, 'hari');
      expect(d.startAt, DateTime(2026, 9, 26, 18));
      expect(d.endAt, DateTime(2026, 9, 26, 19));
      expect(d.priceAmount, 200); // 2000 / 10 players
      expect(d.isIndoor, isTrue);

      final manual = d.withoutBooking();
      expect(manual.booking, isNull);
      expect(manual.venue?.venueId, isNull);
      expect(manual.venue?.name, 'Dhuku Futsal');
    });

    test('create flow skips the date and time steps when booked', () {
      final draft =
          const MatchDraft(
            id: 'd',
            organizerId: 'raj',
            title: 'Booked game',
          ).bookSlot(
            dhuku,
            slot('s1', DateTime.now().add(const Duration(days: 2))),
          );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = createMatchControllerProvider(draft);
      final c = container.read(provider.notifier)
        ..goTo(CreateMatchStep.venue)
        ..next();
      expect(container.read(provider).step, CreateMatchStep.format);
      c.back();
      expect(container.read(provider).step, CreateMatchStep.venue);
    });
  });

  group('venue owner app', () {
    late FakeVenueRepository venues;
    const ownerUser = AuthUser(uid: 'hari', email: 'hari@example.com');

    setUp(() => venues = FakeVenueRepository(owners: [hari], venues: [dhuku]));

    Future<void> enter(WidgetTester tester, String key, String text) async {
      final f = find.byKey(Key(key));
      await tester.scrollUntilVisible(
        f,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(f, text);
    }

    testWidgets('sign up as a venue owner and set up the venue', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..nextUser = const AuthUser(uid: 'newowner', email: 'o@example.com');
      venues = FakeVenueRepository();
      await pumpApp(tester, auth: auth, venues: venues, now: testNow);

      await tester.tapVisible(find.byKey(const Key('accountMode_owner')));
      expect(
        find.text('Sign in to manage your venue and bookings.'),
        findsOneWidget,
      );
      await tester.tapVisible(find.text('Create account'));
      expect(find.text('List your venue'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'o@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password1',
      );
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        'password1',
      );
      await tester.tapVisible(find.byKey(const Key('signUpButton')));
      expect(find.text('Set up your venue'), findsOneWidget);

      await enter(tester, 'ownerNameInput', 'Gita Owner');
      await enter(tester, 'ownerPhoneInput', '9811111111');
      await enter(tester, 'venueNameInput', 'Kick Arena');
      await enter(tester, 'venueCityInput', 'Lalitpur');
      await enter(tester, 'venuePhoneInput', '9811111111');
      await enter(tester, 'venuePriceInput', '1800');
      await tester.tapVisible(find.byKey(const Key('createVenueButton')));

      expect(venues.owners['newowner']?.name, 'Gita Owner');
      expect(venues.venues['newowner']?.name, 'Kick Arena');
      expect(venues.venues['newowner']?.pricePerHour, 1800);
      // Now in the owner app.
      expect(find.byKey(const Key('addSlotsButton')), findsOneWidget);
      expect(find.text('Kick Arena'), findsOneWidget);
    });

    testWidgets('a player can switch the setup to venue owner', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        venues: venues,
      );
      expect(find.text('Step 1 of 5'), findsOneWidget);
      await tester.tapVisible(find.byKey(const Key('switchToOwnerSetup')));
      expect(find.text('Set up your venue'), findsOneWidget);
    });

    testWidgets('owner adds a day of slots', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: ownerUser),
        venues: venues,
        now: testNow,
      );
      expect(find.text('No slots this day'), findsOneWidget);
      await tester.tapVisible(find.byKey(const Key('addSlotsButton')));
      // Default 6:00–22:00, 1-hour slots, price from the venue.
      await tester.tapVisible(find.byKey(const Key('saveSlotsButton')));

      // It's 10:00, so 11:00 … 21:00 = 11 slots.
      expect(venues.slots.length, 11);
      expect(venues.slots.values.first.price, 2000);
      expect(find.text('0 booked · 11 free'), findsOneWidget);
      expect(find.text('Added 11 slots'), findsOneWidget);
    });

    testWidgets('owner removes a free slot and cancels a booked one', (
      tester,
    ) async {
      venues = FakeVenueRepository(
        owners: [hari],
        venues: [dhuku],
        slots: [
          slot('free1', DateTime(2026, 9, 25, 17)),
          slot(
            'booked1',
            DateTime(2026, 9, 25, 18),
            status: SlotStatus.booked,
            booking: (
              matchId: 'm1',
              matchTitle: 'Friday Futsal',
              organizerId: 'raj',
              organizerName: 'Raj Shrestha',
            ),
          ),
        ],
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: ownerUser),
        venues: venues,
        now: testNow,
      );
      expect(find.text('📅 Friday Futsal · by Raj Shrestha'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('slot_free1')));
      await tester.tapVisible(find.byKey(const Key('removeSlotButton')));
      expect(venues.slots.containsKey('free1'), isFalse);

      await tester.tapVisible(find.byKey(const Key('slot_booked1')));
      await tester.enterText(
        find.byKey(const Key('cancelReasonField')),
        'Pitch repairs',
      );
      await tester.tapVisible(find.byKey(const Key('cancelBookingButton')));
      expect(venues.cancelled, {'booked1': 'Pitch repairs'});
    });

    testWidgets('owner switches slots between booked and free', (tester) async {
      venues = FakeVenueRepository(
        owners: [hari],
        venues: [dhuku],
        slots: [
          slot('a', DateTime(2026, 9, 25, 17)),
          slot('b', DateTime(2026, 9, 25, 18)),
        ],
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: ownerUser),
        venues: venues,
        now: testNow,
      );
      expect(find.text('0 booked · 2 free'), findsOneWidget);

      // Quick switch: booked (phone / walk-in).
      await tester.tapVisible(find.byKey(const Key('toggle_a')));
      expect(venues.slots['a']!.bookedOffline, isTrue);
      expect(find.text('1 booked · 1 free'), findsOneWidget);
      expect(find.text('📞 Booked by you'), findsOneWidget);

      // And back to free.
      await tester.tapVisible(find.byKey(const Key('toggle_a')));
      expect(venues.slots['a']!.isFree, isTrue);

      // From the slot sheet, with a note.
      await tester.tapVisible(find.byKey(const Key('slot_b')));
      await tester.enterText(
        find.byKey(const Key('offlineNoteField')),
        'Ram’s team',
      );
      await tester.tapVisible(find.byKey(const Key('markBookedButton')));
      expect(venues.slots['b']!.offlineNote, 'Ram’s team');
      expect(find.text('📞 Booked by you · Ram’s team'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('slot_b')));
      await tester.tapVisible(find.byKey(const Key('markFreeButton')));
      expect(venues.slots['b']!.isFree, isTrue);
    });

    testWidgets('app bookings have no switch (cancel from the sheet)', (
      tester,
    ) async {
      venues = FakeVenueRepository(
        owners: [hari],
        venues: [dhuku],
        slots: [
          slot(
            'app',
            DateTime(2026, 9, 25, 18),
            status: SlotStatus.booked,
            booking: (
              matchId: 'm1',
              matchTitle: 'Friday Futsal',
              organizerId: 'raj',
              organizerName: 'Raj Shrestha',
            ),
          ),
        ],
      );
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: ownerUser),
        venues: venues,
        now: testNow,
      );
      expect(find.byKey(const Key('toggle_app')), findsNothing);
      await tester.tapVisible(find.byKey(const Key('slot_app')));
      expect(find.byKey(const Key('cancelBookingButton')), findsOneWidget);
    });

    testWidgets('owners stay in the owner app', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: ownerUser),
        venues: venues,
        now: testNow,
      );
      unawaited(
        GoRouter.of(tester.element(find.byType(Scaffold).first))
            .push(AppRoutes.discover),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('addSlotsButton')), findsOneWidget);
      expect(find.byKey(const Key('discoverSearchField')), findsNothing);

      await tester.tap(find.text('Venue'));
      await tester.pumpAndSettle();
      expect(find.text('🏟️ Dhuku Futsal'), findsOneWidget);
      expect(find.text('🅿️ Parking'), findsOneWidget);
    });
  });

  group('players and venues', () {
    late FakeVenueRepository venues;
    final tomorrow6pm = () {
      final t = DateTime.now().add(const Duration(days: 1));
      return DateTime(t.year, t.month, t.day, 18);
    }();

    setUp(
      () => venues = FakeVenueRepository(
        owners: [hari],
        venues: [dhuku],
        slots: [
          slot('s1', tomorrow6pm),
          // Booked by the owner (phone): players see it as taken.
          slot(
            's2',
            tomorrow6pm.add(const Duration(hours: 1)),
            status: SlotStatus.booked,
          ).copyWith(bookedOffline: true),
        ],
      ),
    );

    testWidgets('book a free slot from the venue page', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(profiles: [testProfile()]),
        venues: venues,
      );
      await tester.tap(find.bySemanticsLabel('Discover'));
      await tester.pumpAndSettle();
      await tester.tapVisible(find.byKey(const Key('venuesButton')));
      await tester.tapVisible(find.byKey(const Key('venue_hari')));
      expect(find.text('🏟️ Dhuku Futsal'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('day_1')));
      // Only the free slot is offered.
      expect(find.byKey(const Key('slot_s1')), findsOneWidget);
      expect(find.byKey(const Key('slot_s2')), findsNothing);
      expect(find.text('1 already booked'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('slot_s1')));
      await tester.tapVisible(find.byKey(const Key('confirmBookSlotButton')));

      // The create flow opens with the booking; date and time are skipped.
      await tester.enterText(
        find.byKey(const Key('matchTitleField')),
        'Booked futsal',
      );
      await tester.tapVisible(find.byKey(const Key('createMatchNextButton')));
      expect(find.byKey(const Key('bookedVenueCard')), findsOneWidget);
      await tester.tapVisible(find.byKey(const Key('createMatchNextButton')));
      expect(find.text(CreateMatchStep.format.heading), findsOneWidget);
    });

    testWidgets('pick a venue slot from the create flow', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(signedIn: testUser),
        profiles: FakeProfileRepository(profiles: [testProfile()]),
        venues: venues,
      );
      await tester.tapVisible(find.byKey(const Key('createMatchButton')));
      await tester.tapVisible(find.byKey(const Key('newMatchButton')));
      await tester.enterText(find.byKey(const Key('matchTitleField')), 'Game');
      await tester.tapVisible(find.byKey(const Key('createMatchNextButton')));

      await tester.tapVisible(find.byKey(const Key('bookVenueButton')));
      expect(find.text('Book a venue'), findsOneWidget);
      await tester.tapVisible(find.byKey(const Key('venue_hari')));
      await tester.tapVisible(find.byKey(const Key('day_1')));
      await tester.tapVisible(find.byKey(const Key('slot_s1')));

      expect(find.byKey(const Key('bookedVenueCard')), findsOneWidget);
      expect(find.text('🏟️ Dhuku Futsal'), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('removeBookingButton')));
      expect(find.byKey(const Key('venueNameField')), findsOneWidget);
    });

    group('after a match at the venue', () {
      FootballMatch playedAtVenue({MatchBooking? booking}) {
        final end = DateTime.now().subtract(const Duration(days: 1));
        return testMatch(
          status: MatchStatus.completed,
          currentPlayers: 1,
        ).copyWith(
          startAt: end.subtract(const Duration(hours: 1)),
          endAt: end,
          venue: testVenue.copyWith(venueId: 'hari', name: 'Dhuku Futsal'),
          booking: booking,
        );
      }

      testWidgets('a player who played rates the venue', (tester) async {
        final matches = FakeMatchRepository(matches: [playedAtVenue()]);
        final requests = FakeMatchRequestRepository(matches)
          ..seedRoster('m1', [
            RosterEntry(
              player: MatchRequestMapper.cardFromProfile(testProfile()),
              group: PositionGroup.mid,
            ),
          ]);
        await pumpApp(
          tester,
          auth: FakeAuthRepository(signedIn: testUser),
          profiles: FakeProfileRepository(profiles: [testProfile()]),
          matches: matches,
          requests: requests,
          venues: venues,
        );
        unawaited(
          GoRouter.of(tester.element(find.byType(Scaffold).first))
              .push(AppRoutes.matchDetails('m1')),
        );
        await tester.pumpAndSettle();

        await tester.tapVisible(find.byKey(const Key('rateVenueButton')));
        final submit = find.byKey(const Key('submitVenueRatingButton'));
        expect(tester.widget<FilledButton>(submit).onPressed, isNull);
        for (final (part, stars) in [
          (RatingPart.overall, 4),
          (RatingPart.pitch, 5),
          (RatingPart.facilities, 3),
          (RatingPart.value, 4),
        ]) {
          await tester.tapVisible(
            find.byKey(Key('venueStar_${part.name}_$stars')),
          );
        }
        await tester.enterText(
          find.byKey(const Key('venueRatingComment')),
          'Great turf',
        );
        await tester.tapVisible(submit);

        final r = venues.ratings.single;
        expect(r.venueId, 'hari');
        expect(r.matchId, 'm1');
        expect((r.overall, r.pitch, r.facilities, r.value), (4, 5, 3, 4));
        expect(r.comment, 'Great turf');
        // Rated: the button goes away.
        expect(find.byKey(const Key('rateVenueButton')), findsNothing);

        // The venue link (higher up) opens the venue page.
        await tester.scrollUntilVisible(
          find.byKey(const Key('venueLink')),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tapVisible(find.byKey(const Key('venueLink')));
        expect(find.text('Free times'), findsOneWidget);
      });

      testWidgets('a cancelled booking is flagged on the match', (
        tester,
      ) async {
        final m = testMatch().copyWith(
          venue: testVenue.copyWith(venueId: 'hari', name: 'Dhuku Futsal'),
          booking: (
            venueId: 'hari',
            slotId: 's1',
            status: BookingStatus.cancelledByVenue,
            reason: 'Pitch repairs',
          ),
        );
        await pumpApp(
          tester,
          auth: FakeAuthRepository(signedIn: testUser),
          profiles: FakeProfileRepository(profiles: [testProfile()]),
          matches: FakeMatchRepository(matches: [m]),
          venues: venues,
        );
        await tester.tapVisible(find.text('⚽ Saturday Night Football'));
        expect(find.byKey(const Key('venueCancelledBanner')), findsOneWidget);
        expect(find.textContaining('Pitch repairs'), findsOneWidget);
        expect(find.textContaining('Contact the venue'), findsOneWidget);
      });
    });
  });

  test('formats of a venue default to 5v5', () {
    expect(dhuku.formats, {MatchFormat.fiveASide});
  });
}
