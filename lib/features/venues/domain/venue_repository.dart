import 'dart:typed_data';

import 'venue_models.dart';

/// Venue owners, venues, their time slots and ratings.
abstract interface class VenueRepository {
  Stream<OwnerProfile?> watchOwner(String uid);

  Stream<VenueProfile?> watchVenue(String venueId);

  /// All venues, by name.
  Stream<List<VenueProfile>> watchVenues({int limit = 100});

  /// Slots starting in [from, to), by start time.
  Stream<List<VenueSlot>> watchSlots(
    String venueId, {
    required DateTime from,
    required DateTime to,
  });

  Stream<List<VenueRating>> watchRatings(String venueId, {int limit = 30});

  /// Whether [uid] already rated [venueId] for [matchId].
  Stream<bool> watchHasRated(String venueId, String matchId, String uid);

  /// Creates the owner profile and their venue together (onboarding).
  Future<void> createOwner(OwnerProfile owner, VenueProfile venue);

  Future<void> updateOwner(OwnerProfile owner);

  Future<void> updateVenue(VenueProfile venue);

  Future<String> uploadVenuePhoto(String venueId, Uint8List bytes);

  Future<void> addSlots(String venueId, List<NewSlot> slots);

  /// Removes a free (or offline-booked) slot.
  Future<void> deleteSlot(String venueId, String slotId);

  /// Owner marks a free slot booked outside the app (phone, walk-in).
  Future<void> markBookedOffline(
    String venueId,
    String slotId, {
    String note = '',
  });

  /// Owner frees a slot they had marked booked.
  Future<void> markFree(String venueId, String slotId);

  /// Owner cancels a booked slot; the organizer is notified.
  Future<void> cancelBooking(String slotId, {String reason = ''});

  Future<void> rateVenue(VenueRating rating);
}
