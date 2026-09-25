import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/create_match_step.dart';
import '../../domain/match_draft.dart';

part 'create_match_state.freezed.dart';

@freezed
abstract class CreateMatchState with _$CreateMatchState {
  const factory CreateMatchState({
    required MatchDraft draft,
    @Default(CreateMatchStep.title) CreateMatchStep step,

    /// Saving, uploading or publishing.
    @Default(false) bool busy,

    /// Changed since the last save.
    @Default(false) bool dirty,
  }) = _CreateMatchState;
}
