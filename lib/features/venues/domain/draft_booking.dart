import '../../../shared/models/venue.dart';
import '../../matches/domain/match_draft.dart';
import 'venue_models.dart';

/// Booking a venue slot from the create-match flow.
extension DraftBookingX on MatchDraft {
  /// Fills venue, day and times from [slot] and marks it to be booked on
  /// publish. The per-player price is suggested from the slot price if the
  /// organizer hasn't set one.
  MatchDraft bookSlot(VenueProfile venue, VenueSlot slot) {
    final day = DateTime(
      slot.startAt.year,
      slot.startAt.month,
      slot.startAt.day,
    );
    const minutesPerDay = 24 * 60;
    return copyWith(
      booking: (venueId: venue.id, slotId: slot.id),
      venue: Venue(
        name: venue.name,
        address: venue.address,
        city: venue.city,
        venueId: venue.id,
      ),
      date: day,
      startMinutes: slot.startAt.difference(day).inMinutes,
      // Past midnight wraps; MatchDraft.endAt handles the next day.
      endMinutes: slot.endAt.difference(day).inMinutes % minutesPerDay,
      isIndoor: venue.isIndoor,
      priceAmount: priceAmount == 0 && maxPlayers > 0
          ? (slot.price / maxPlayers).ceil()
          : priceAmount,
    );
  }

  /// Back to typing the venue and time by hand.
  MatchDraft withoutBooking() =>
      copyWith(booking: null, venue: venue?.copyWith(venueId: null));
}
