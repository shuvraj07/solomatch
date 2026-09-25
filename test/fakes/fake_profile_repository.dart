import 'dart:async';
import 'dart:typed_data';

import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/profile/domain/player_profile.dart';
import 'package:solomatch/features/profile/domain/profile_repository.dart';

/// In-memory [ProfileRepository] with realtime [watchProfile].
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({Iterable<PlayerProfile> profiles = const []}) {
    for (final p in profiles) {
      _profiles[p.uid] = p;
      takenUsernames.add(p.username);
    }
  }

  final _profiles = <String, PlayerProfile>{};
  final _changes = StreamController<String>.broadcast();
  final takenUsernames = <String>{};
  final uploads = <String>[];

  PlayerProfile? profileOf(String uid) => _profiles[uid];

  @override
  Stream<PlayerProfile?> watchProfile(String uid) async* {
    yield _profiles[uid];
    yield* _changes.stream.where((id) => id == uid).map((_) => _profiles[uid]);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async =>
      !takenUsernames.contains(username.toLowerCase());

  @override
  Future<void> createProfile(
    PlayerProfile profile, {
    required String? email,
  }) async {
    if (takenUsernames.contains(profile.username)) {
      throw const ValidationFailure('That username was just taken.');
    }
    takenUsernames.add(profile.username);
    _profiles[profile.uid] = profile;
    _changes.add(profile.uid);
  }

  @override
  Future<void> updateProfile(PlayerProfile profile) async {
    _profiles[profile.uid] = profile;
    _changes.add(profile.uid);
  }

  @override
  Future<String> uploadProfilePhoto(String uid, Uint8List bytes) async {
    uploads.add(uid);
    return 'https://example.com/$uid.jpg';
  }
}
