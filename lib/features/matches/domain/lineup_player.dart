import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/position.dart';
import '../../../shared/models/position_group.dart';

part 'lineup_player.freezed.dart';

/// A SoloMatch user the organizer has already confirmed for the match
/// ("my friends are coming"). They go straight onto the roster when the
/// match is published, are notified, and can leave if they can't make it.
@freezed
abstract class LineupPlayer with _$LineupPlayer {
  const factory LineupPlayer({
    required String uid,
    required String name,
    required String username,
    String? photoUrl,
    required Position primaryPosition,

    /// Slot the organizer wants them in; defaults to their main position.
    required PositionGroup group,
  }) = _LineupPlayer;
}
