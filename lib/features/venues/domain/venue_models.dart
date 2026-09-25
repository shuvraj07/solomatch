import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/match_format.dart';

part 'venue_models.freezed.dart';

/// Facilities a venue can list. Stored by [wireName].
enum Amenity {
  parking('Parking', '🅿️', 'parking'),
  changingRoom('Changing room', '🚪', 'changing_room'),
  showers('Showers', '🚿', 'showers'),
  drinkingWater('Drinking water', '💧', 'drinking_water'),
  floodlights('Floodlights', '💡', 'floodlights'),
  cafe('Café / snacks', '☕', 'cafe'),
  bibs('Bibs', '🎽', 'bibs'),
  balls('Balls provided', '⚽', 'balls');

  const Amenity(this.label, this.emoji, this.wireName);

  final String label;
  final String emoji;
  final String wireName;

  static Amenity? fromWire(String name) =>
      values.where((a) => a.wireName == name).firstOrNull;
}

/// A venue owner's business contact (`owners/{uid}`).
@freezed
abstract class OwnerProfile with _$OwnerProfile {
  const factory OwnerProfile({
    required String uid,
    required String name,
    required String phone,
  }) = _OwnerProfile;
}

/// Average scores from players' venue ratings (server-maintained).
typedef VenueRatingSummary = ({
  int count,
  double overall,
  double pitch,
  double facilities,
  double value,
});

/// A futsal or pitch listed by its owner (`venues/{ownerUid}`).
@freezed
abstract class VenueProfile with _$VenueProfile {
  const factory VenueProfile({
    /// Same as the owner's uid: one venue per owner account.
    required String id,
    required String name,
    @Default('') String address,
    required String city,
    required String phone,
    @Default('') String description,
    @Default(true) bool isIndoor,
    @Default(<MatchFormat>{MatchFormat.fiveASide}) Set<MatchFormat> formats,

    /// Usual price for the pitch per hour, NPR. Each slot has its own price.
    @Default(0) int pricePerHour,
    @Default(<Amenity>{}) Set<Amenity> amenities,
    @Default(<String>[]) List<String> photos,
    VenueRatingSummary? rating,
  }) = _VenueProfile;

  const VenueProfile._();

  String get shortLabel => address.isEmpty ? city : '$address, $city';
}

enum SlotStatus { free, booked }

/// Who booked a slot (server-written).
typedef SlotBooking = ({
  String matchId,
  String matchTitle,
  String organizerId,
  String organizerName,
});

/// A bookable time at a venue (`venues/{venueId}/slots/{slotId}`).
@freezed
abstract class VenueSlot with _$VenueSlot {
  const factory VenueSlot({
    required String id,
    required String venueId,
    required DateTime startAt,
    required DateTime endAt,

    /// Price for the whole pitch for this slot, NPR.
    required int price,
    required SlotStatus status,
    SlotBooking? booking,
  }) = _VenueSlot;

  const VenueSlot._();

  bool get isFree => status == SlotStatus.free;

  bool overlaps(DateTime start, DateTime end) =>
      start.isBefore(endAt) && end.isAfter(startAt);
}

/// A slot the owner is about to add.
typedef NewSlot = ({DateTime startAt, DateTime endAt, int price});

/// A player's rating of a venue after a match there
/// (`venues/{venueId}/ratings/{matchId}_{uid}`).
@freezed
abstract class VenueRating with _$VenueRating {
  const factory VenueRating({
    required String venueId,
    required String matchId,
    required String matchTitle,
    required String reviewerId,
    required String reviewerName,
    String? reviewerPhotoUrl,
    required int overall,
    required int pitch,
    required int facilities,
    required int value,
    @Default('') String comment,
    DateTime? createdAt,
  }) = _VenueRating;
}

/// The parts players score, in display order.
enum RatingPart {
  overall('Overall'),
  pitch('Pitch quality'),
  facilities('Facilities'),
  value('Value for money');

  const RatingPart(this.label);

  final String label;
}
