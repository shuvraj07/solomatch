import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solomatch/features/matches/data/match_mapper.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/shared/models/user_summary.dart';

/// Writes a published match straight into a (fake) Firestore, in the same
/// shape the `publishDraft` Cloud Function produces for a match with no
/// pre-confirmed players. Publishing itself runs on the server, which a
/// fake Firestore can't execute.
Future<void> seedMatch(
  FirebaseFirestore db,
  MatchDraft draft,
  UserSummary organizer,
) => db
    .collection('matches')
    .doc(draft.id)
    .set(MatchMapper.newMatch(draft, organizer));
