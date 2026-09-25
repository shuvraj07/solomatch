import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// An inbox entry (Firestore `users/{uid}/notifications/{id}`), written by
/// Cloud Functions alongside each push.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,

    /// e.g. `request_accepted`, `match_reminder` (see functions/src/notifications).
    required String type,
    required String title,
    required String body,
    String? matchId,
    @Default(false) bool read,
    DateTime? createdAt,
  }) = _AppNotification;

  const AppNotification._();

  String get emoji => switch (type) {
    'new_request' => '🙋',
    'request_accepted' => '✅',
    'request_rejected' => '❌',
    'player_left' => '🚶',
    'match_almost_full' || 'match_full' => '👥',
    'match_cancelled' => '🚫',
    'match_reminder' => '⏰',
    'kick_off' => '⚽',
    'request_expired' => '⌛',
    'report_reminder' => '📝',
    'added_to_match' => '🤝',
    'motm_vote' || 'motm_won' => '🏆',
    _ => '⚽',
  };
}

/// A push as delivered to the device.
typedef PushMessage = ({String title, String body, String? route});
