import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_summary.freezed.dart';

/// Small copy of a player's identity stored inside other documents
/// (a match's organizer, a roster entry) so lists render without extra reads.
@freezed
abstract class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String uid,
    required String name,
    required String username,
    String? photoUrl,
  }) = _UserSummary;
}
