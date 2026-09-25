import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';

/// Where a match is played. Coordinates and [placeId] come from the map
/// picker; until a pin is chosen they are null.
@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required String name,
    @Default('') String address,
    required String city,
    String? placeId,
    double? lat,
    double? lng,
  }) = _Venue;

  const Venue._();

  bool get hasLocation => lat != null && lng != null;

  /// "Futsal Arena, Baneshwor" or just the name.
  String get shortLabel => address.isEmpty ? name : '$name, $address';
}
