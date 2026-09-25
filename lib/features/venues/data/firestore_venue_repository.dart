import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_failure.dart';
import '../../../shared/models/match_format.dart';
import '../domain/venue_models.dart';
import '../domain/venue_repository.dart';

class FirestoreVenueRepository implements VenueRepository {
  FirestoreVenueRepository(this._db, this._storage, this._functions);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _venues =>
      _db.collection('venues');

  CollectionReference<Map<String, dynamic>> _slots(String venueId) =>
      _venues.doc(venueId).collection('slots');

  CollectionReference<Map<String, dynamic>> _ratings(String venueId) =>
      _venues.doc(venueId).collection('ratings');

  @override
  Stream<OwnerProfile?> watchOwner(String uid) =>
      _db.collection('owners').doc(uid).snapshots().map((s) {
        final d = s.data();
        if (d == null) return null;
        return OwnerProfile(
          uid: uid,
          name: d['name'] as String? ?? '',
          phone: d['phone'] as String? ?? '',
        );
      });

  @override
  Stream<VenueProfile?> watchVenue(String venueId) =>
      _venues.doc(venueId).snapshots().map((s) {
        final d = s.data();
        return d == null ? null : VenueMapper.venueFrom(s.id, d);
      });

  @override
  Stream<List<VenueProfile>> watchVenues({int limit = 100}) => _venues
      .orderBy('searchName')
      .limit(limit)
      .snapshots()
      .map(
        (q) => [for (final d in q.docs) VenueMapper.venueFrom(d.id, d.data())],
      );

  @override
  Stream<List<VenueSlot>> watchSlots(
    String venueId, {
    required DateTime from,
    required DateTime to,
  }) => _slots(venueId)
      .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
      .where('startAt', isLessThan: Timestamp.fromDate(to))
      .orderBy('startAt')
      .snapshots()
      .map(
        (q) => [
          for (final d in q.docs) VenueMapper.slotFrom(venueId, d.id, d.data()),
        ],
      );

  @override
  Stream<List<VenueRating>> watchRatings(String venueId, {int limit = 30}) =>
      _ratings(venueId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs) VenueMapper.ratingFrom(venueId, d.data()),
            ],
          );

  @override
  Stream<bool> watchHasRated(String venueId, String matchId, String uid) =>
      _ratings(venueId).doc('${matchId}_$uid').snapshots().map((s) => s.exists);

  @override
  Future<void> createOwner(OwnerProfile owner, VenueProfile venue) =>
      _guard(() {
        final batch = _db.batch()
          ..set(_db.collection('owners').doc(owner.uid), {
            'name': owner.name.trim(),
            'phone': owner.phone.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        return (batch..set(_venues.doc(owner.uid), {
              ...VenueMapper.venueTo(venue),
              'ownerId': owner.uid,
              'createdAt': FieldValue.serverTimestamp(),
            }))
            .commit();
      });

  @override
  Future<void> updateOwner(OwnerProfile owner) => _guard(
    () => _db.collection('owners').doc(owner.uid).update({
      'name': owner.name.trim(),
      'phone': owner.phone.trim(),
    }),
  );

  @override
  Future<void> updateVenue(VenueProfile venue) =>
      _guard(() => _venues.doc(venue.id).update(VenueMapper.venueTo(venue)));

  @override
  Future<String> uploadVenuePhoto(String venueId, Uint8List bytes) async {
    try {
      final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref('venue_photos/$venueId/$name');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException {
      throw const UnknownFailure("Couldn't upload the photo. Try again.");
    }
  }

  @override
  Future<void> addSlots(String venueId, List<NewSlot> slots) => _guard(() {
    final batch = _db.batch();
    for (final s in slots) {
      batch.set(_slots(venueId).doc(), {
        'startAt': Timestamp.fromDate(s.startAt),
        'endAt': Timestamp.fromDate(s.endAt),
        'price': s.price,
        'status': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return batch.commit();
  });

  @override
  Future<void> deleteSlot(String venueId, String slotId) =>
      _guard(() => _slots(venueId).doc(slotId).delete());

  @override
  Future<void> markBookedOffline(
    String venueId,
    String slotId, {
    String note = '',
  }) => _guard(
    () => _slots(venueId).doc(slotId).update({
      'status': 'booked',
      'booking': {
        'offline': true,
        'note': note.trim(),
        'markedAt': FieldValue.serverTimestamp(),
      },
    }),
  );

  @override
  Future<void> markFree(String venueId, String slotId) => _guard(
    () =>
        _slots(venueId)
            .doc(slotId)
            .update({'status': 'free', 'booking': FieldValue.delete()}),
  );

  @override
  Future<void> cancelBooking(String slotId, {String reason = ''}) async {
    try {
      await _functions.httpsCallable('cancelVenueBooking').call<Object?>({
        'slotId': slotId,
        'reason': reason,
      });
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? const UnknownFailure().message;
      throw switch (e.code) {
        'failed-precondition' || 'not-found' => ValidationFailure(message),
        'permission-denied' => PermissionFailure(message),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        _ => const UnknownFailure(),
      };
    }
  }

  @override
  Future<void> rateVenue(VenueRating r) => _guard(
    () => _ratings(r.venueId).doc('${r.matchId}_${r.reviewerId}').set({
      'matchId': r.matchId,
      'reviewerId': r.reviewerId,
      'overall': r.overall,
      'pitch': r.pitch,
      'facilities': r.facilities,
      'value': r.value,
      'comment': r.comment.trim(),
      'reviewer': {'name': r.reviewerName, 'photoUrl': r.reviewerPhotoUrl},
      'matchTitle': r.matchTitle,
      'createdAt': FieldValue.serverTimestamp(),
    }),
  );

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw switch (e.code) {
        'permission-denied' => const PermissionFailure(),
        'unavailable' => const NetworkFailure(),
        'not-found' => const NotFoundFailure(),
        _ => const UnknownFailure(),
      };
    }
  }
}

/// Venue documents ↔ models. Field names are documented in
/// docs/firestore-schema.md.
abstract final class VenueMapper {
  static VenueProfile venueFrom(String id, Map<String, dynamic> d) {
    final r = d['rating'] as Map<String, dynamic>?;
    double avg(String k) => (r?[k] as num?)?.toDouble() ?? 0;
    return VenueProfile(
      id: id,
      name: d['name'] as String? ?? '',
      address: d['address'] as String? ?? '',
      city: d['city'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      description: d['description'] as String? ?? '',
      isIndoor: d['isIndoor'] as bool? ?? false,
      formats: {
        for (final f in d['formats'] as List<Object?>? ?? const [])
          ?MatchFormat.values.asNameMap()[f],
      },
      pricePerHour: (d['pricePerHour'] as num?)?.toInt() ?? 0,
      amenities: {
        for (final a in d['amenities'] as List<Object?>? ?? const [])
          ?Amenity.fromWire(a! as String),
      },
      photos: [
        for (final p in d['photos'] as List<Object?>? ?? const []) p! as String,
      ],
      rating: r == null || (r['count'] as num? ?? 0) == 0
          ? null
          : (
              count: (r['count'] as num).toInt(),
              overall: avg('overall'),
              pitch: avg('pitch'),
              facilities: avg('facilities'),
              value: avg('value'),
            ),
    );
  }

  /// Owner-editable fields (never `rating`).
  static Map<String, dynamic> venueTo(VenueProfile v) {
    final name = v.name.trim();
    return {
      'name': name,
      'searchName': name.toLowerCase(),
      'address': v.address.trim(),
      'city': v.city.trim(),
      'phone': v.phone.trim(),
      'description': v.description.trim(),
      'isIndoor': v.isIndoor,
      'formats': [
        for (final f in MatchFormat.values)
          if (v.formats.contains(f)) f.name,
      ],
      'pricePerHour': v.pricePerHour,
      'amenities': [
        for (final a in Amenity.values)
          if (v.amenities.contains(a)) a.wireName,
      ],
      'photos': v.photos,
      'lat': null,
      'lng': null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static VenueSlot slotFrom(
    String venueId,
    String id,
    Map<String, dynamic> d,
  ) => VenueSlot(
    id: id,
    venueId: venueId,
    startAt: (d['startAt'] as Timestamp).toDate(),
    endAt: (d['endAt'] as Timestamp).toDate(),
    price: (d['price'] as num?)?.toInt() ?? 0,
    status: d['status'] == 'booked' ? SlotStatus.booked : SlotStatus.free,
    bookedOffline: (d['booking'] as Map?)?['offline'] == true,
    offlineNote: (d['booking'] as Map?)?['note'] as String? ?? '',
    booking: switch (d['booking']) {
      final Map<String, dynamic> b when b['offline'] != true => (
        matchId: b['matchId'] as String? ?? '',
        matchTitle: b['matchTitle'] as String? ?? '',
        organizerId: b['organizerId'] as String? ?? '',
        organizerName: b['organizerName'] as String? ?? '',
      ),
      _ => null,
    },
  );

  static VenueRating ratingFrom(String venueId, Map<String, dynamic> d) {
    final reviewer = d['reviewer'] as Map<String, dynamic>? ?? const {};
    int n(String k) => (d[k] as num?)?.toInt() ?? 0;
    return VenueRating(
      venueId: venueId,
      matchId: d['matchId'] as String? ?? '',
      matchTitle: d['matchTitle'] as String? ?? '',
      reviewerId: d['reviewerId'] as String? ?? '',
      reviewerName: reviewer['name'] as String? ?? 'Player',
      reviewerPhotoUrl: reviewer['photoUrl'] as String?,
      overall: n('overall'),
      pitch: n('pitch'),
      facilities: n('facilities'),
      value: n('value'),
      comment: d['comment'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
