import '../../../domain/match_draft.dart';

/// Applies a change to the draft being edited.
typedef DraftUpdate = void Function(MatchDraft Function(MatchDraft d) change);
