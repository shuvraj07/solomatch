import 'dart:async';

import 'package:solomatch/features/safety/domain/safety_repository.dart';
import 'package:solomatch/features/settings/domain/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  final prefs = <NotificationCategory, bool>{
    for (final c in NotificationCategory.values) c: true,
  };
  final _changes = StreamController<void>.broadcast();
  var deleted = false;

  @override
  Stream<NotificationPrefs> watchNotificationPrefs(String uid) async* {
    yield Map.of(prefs);
    yield* _changes.stream.map((_) => Map.of(prefs));
  }

  @override
  Future<void> setNotificationPref(
    String uid,
    NotificationCategory category,
    bool enabled,
  ) async {
    prefs[category] = enabled;
    _changes.add(null);
  }

  @override
  Future<void> deleteAccount() async => deleted = true;
}

typedef FiledReport = ({
  ReportTarget type,
  String targetId,
  ReportReason reason,
  String details,
});

class FakeSafetyRepository implements SafetyRepository {
  final blocked = <String, String>{}; // uid -> name
  final reports = <FiledReport>[];
  final _changes = StreamController<void>.broadcast();

  List<BlockedPlayer> _list() => [
    for (final e in blocked.entries) (uid: e.key, name: e.value),
  ];

  @override
  Stream<List<BlockedPlayer>> watchBlocked(String uid) async* {
    yield _list();
    yield* _changes.stream.map((_) => _list());
  }

  @override
  Future<void> block(String uid, BlockedPlayer player) async {
    blocked[player.uid] = player.name;
    _changes.add(null);
  }

  @override
  Future<void> unblock(String uid, String blockedUid) async {
    blocked.remove(blockedUid);
    _changes.add(null);
  }

  @override
  Future<void> report({
    required String reporterId,
    required ReportTarget type,
    required String targetId,
    required String targetName,
    required ReportReason reason,
    String details = '',
  }) async => reports.add((
    type: type,
    targetId: targetId,
    reason: reason,
    details: details,
  ));
}
