import 'dart:async';
import 'dart:typed_data';

import 'package:solomatch/features/venues/domain/venue_models.dart';
import 'package:solomatch/features/venues/domain/venue_repository.dart';

/// In-memory [VenueRepository].
class FakeVenueRepository implements VenueRepository {
  FakeVenueRepository({
    Iterable<OwnerProfile> owners = const [],
    Iterable<VenueProfile> venues = const [],
    Iterable<VenueSlot> slots = const [],
  }) {
    for (final o in owners) {
      this.owners[o.uid] = o;
    }
    for (final v in venues) {
      this.venues[v.id] = v;
    }
    for (final s in slots) {
      this.slots[s.id] = s;
    }
  }

  final owners = <String, OwnerProfile>{};
  final venues = <String, VenueProfile>{};
  final slots = <String, VenueSlot>{};
  final ratings = <VenueRating>[];
  final cancelled = <String, String>{}; // slotId -> reason
  final _changes = StreamController<void>.broadcast();
  var _nextId = 0;

  void _changed() => _changes.add(null);

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<OwnerProfile?> watchOwner(String uid) => _live(() => owners[uid]);

  @override
  Stream<VenueProfile?> watchVenue(String venueId) =>
      _live(() => venues[venueId]);

  @override
  Stream<List<VenueProfile>> watchVenues({int limit = 100}) => _live(
    () => venues.values.toList()..sort((a, b) => a.name.compareTo(b.name)),
  );

  @override
  Stream<List<VenueSlot>> watchSlots(
    String venueId, {
    required DateTime from,
    required DateTime to,
  }) => _live(
    () =>
        slots.values
            .where(
              (s) =>
                  s.venueId == venueId &&
                  !s.startAt.isBefore(from) &&
                  s.startAt.isBefore(to),
            )
            .toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt)),
  );

  @override
  Stream<List<VenueRating>> watchRatings(String venueId, {int limit = 30}) =>
      _live(() => ratings.where((r) => r.venueId == venueId).toList());

  @override
  Stream<bool> watchHasRated(String venueId, String matchId, String uid) =>
      _live(
        () => ratings.any(
          (r) =>
              r.venueId == venueId &&
              r.matchId == matchId &&
              r.reviewerId == uid,
        ),
      );

  @override
  Future<void> createOwner(OwnerProfile owner, VenueProfile venue) async {
    venues[venue.id] = venue;
    owners[owner.uid] = owner;
    _changed();
  }

  @override
  Future<void> updateOwner(OwnerProfile owner) async {
    owners[owner.uid] = owner;
    _changed();
  }

  @override
  Future<void> updateVenue(VenueProfile venue) async {
    venues[venue.id] = venue;
    _changed();
  }

  @override
  Future<String> uploadVenuePhoto(String venueId, Uint8List bytes) async =>
      'https://example.com/venue.jpg';

  @override
  Future<void> addSlots(String venueId, List<NewSlot> newSlots) async {
    for (final s in newSlots) {
      final id = 'slot${_nextId++}';
      slots[id] = VenueSlot(
        id: id,
        venueId: venueId,
        startAt: s.startAt,
        endAt: s.endAt,
        price: s.price,
        status: SlotStatus.free,
      );
    }
    _changed();
  }

  @override
  Future<void> deleteSlot(String venueId, String slotId) async {
    slots.remove(slotId);
    _changed();
  }

  @override
  Future<void> markBookedOffline(
    String venueId,
    String slotId, {
    String note = '',
  }) async {
    slots[slotId] = slots[slotId]!.copyWith(
      status: SlotStatus.booked,
      bookedOffline: true,
      offlineNote: note.trim(),
    );
    _changed();
  }

  @override
  Future<void> markFree(String venueId, String slotId) async {
    slots[slotId] = slots[slotId]!.copyWith(
      status: SlotStatus.free,
      bookedOffline: false,
      offlineNote: '',
    );
    _changed();
  }

  @override
  Future<void> cancelBooking(String slotId, {String reason = ''}) async {
    cancelled[slotId] = reason;
    slots.remove(slotId);
    _changed();
  }

  @override
  Future<void> rateVenue(VenueRating rating) async {
    ratings.add(rating);
    _changed();
  }
}
