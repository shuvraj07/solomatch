import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../domain/venue_models.dart';
import '../domain/venue_repository.dart';
import 'firestore_venue_repository.dart';

final venueRepositoryProvider = Provider<VenueRepository>(
  (ref) => FirestoreVenueRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
    ref.watch(functionsProvider),
  ),
);

/// Owner profile by uid; null if the account isn't a venue owner.
final ownerProfileProvider = StreamProvider.family<OwnerProfile?, String>(
  (ref, uid) => ref.watch(venueRepositoryProvider).watchOwner(uid),
);

final venueProvider = StreamProvider.autoDispose.family<VenueProfile?, String>(
  (ref, id) => ref.watch(venueRepositoryProvider).watchVenue(id),
);

final venuesProvider = StreamProvider.autoDispose<List<VenueProfile>>(
  (ref) => ref.watch(venueRepositoryProvider).watchVenues(),
);

/// Slots of one venue on one calendar day.
typedef VenueDay = ({String venueId, DateTime day});

final venueDaySlotsProvider = StreamProvider.autoDispose
    .family<List<VenueSlot>, VenueDay>((ref, key) {
      final start = DateTime(key.day.year, key.day.month, key.day.day);
      return ref
          .watch(venueRepositoryProvider)
          .watchSlots(
            key.venueId,
            from: start,
            to: start.add(const Duration(days: 1)),
          );
    });

final venueRatingsProvider = StreamProvider.autoDispose
    .family<List<VenueRating>, String>(
      (ref, venueId) =>
          ref.watch(venueRepositoryProvider).watchRatings(venueId),
    );

typedef RatedKey = ({String venueId, String matchId, String uid});

final hasRatedVenueProvider = StreamProvider.autoDispose.family<bool, RatedKey>(
  (ref, k) => ref
      .watch(venueRepositoryProvider)
      .watchHasRated(k.venueId, k.matchId, k.uid),
);
