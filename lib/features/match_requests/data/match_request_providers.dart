import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/join_request.dart';
import '../domain/match_request_repository.dart';
import '../domain/roster_entry.dart';
import 'firestore_match_request_repository.dart';

final matchRequestRepositoryProvider = Provider<MatchRequestRepository>(
  (ref) => FirestoreMatchRequestRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  ),
);

/// The signed-in player's request for a match. Flips to accepted/rejected
/// live when the organizer decides.
final myRequestProvider = StreamProvider.autoDispose
    .family<JoinRequest?, String>((ref, matchId) {
      final uid = ref.watch(currentProfileProvider)?.uid;
      if (uid == null) return Stream.value(null);
      return ref
          .watch(matchRequestRepositoryProvider)
          .watchMyRequest(matchId, uid);
    });

/// Pending requests for the organizer.
final pendingRequestsProvider = StreamProvider.autoDispose
    .family<List<JoinRequest>, String>(
      (ref, matchId) => ref
          .watch(matchRequestRepositoryProvider)
          .watchPendingRequests(matchId),
    );

final rosterProvider = StreamProvider.autoDispose
    .family<List<RosterEntry>, String>(
      (ref, matchId) =>
          ref.watch(matchRequestRepositoryProvider).watchRoster(matchId),
    );
