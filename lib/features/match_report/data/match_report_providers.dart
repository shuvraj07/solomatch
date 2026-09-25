import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/firebase_providers.dart';
import '../../../app/session/session_provider.dart';
import '../domain/match_report_repository.dart';
import 'firestore_match_report_repository.dart';

final matchReportRepositoryProvider = Provider<MatchReportRepository>(
  (ref) => FirestoreMatchReportRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  ),
);

/// Who the signed-in player voted for as Man of the Match.
final myMotmVoteProvider = StreamProvider.autoDispose.family<String?, String>((
  ref,
  matchId,
) {
  final uid = ref.watch(currentProfileProvider)?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(matchReportRepositoryProvider).watchMyVote(matchId, uid);
});
