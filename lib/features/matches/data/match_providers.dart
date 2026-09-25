import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../domain/football_match.dart';
import '../domain/match_draft.dart';
import '../domain/match_repository.dart';
import 'firestore_match_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => FirestoreMatchRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
    ref.watch(functionsProvider),
  ),
);

/// Live match by ID. Every screen showing a match watches this, so roster
/// counts and status update everywhere at once.
final matchProvider = StreamProvider.autoDispose.family<FootballMatch?, String>(
  (ref, id) => ref.watch(matchRepositoryProvider).watchMatch(id),
);

final upcomingMatchesProvider = StreamProvider.autoDispose<List<FootballMatch>>(
  (ref) => ref.watch(matchRepositoryProvider).watchUpcomingMatches(),
);

final liveMatchesProvider = StreamProvider.autoDispose<List<FootballMatch>>(
  (ref) => ref.watch(matchRepositoryProvider).watchLiveMatches(),
);

final myDraftsProvider = StreamProvider.autoDispose
    .family<List<MatchDraft>, String>(
      (ref, uid) => ref.watch(matchRepositoryProvider).watchDrafts(uid),
    );
