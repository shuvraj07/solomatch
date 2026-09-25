import 'dart:typed_data';

import 'player_profile.dart';

abstract interface class ProfileRepository {
  /// Live profile for [uid]; emits `null` while the player has not finished
  /// profile setup.
  Stream<PlayerProfile?> watchProfile(String uid);

  Future<bool> isUsernameAvailable(String username);

  /// Creates the profile and claims its username atomically. Throws
  /// [ValidationFailure] if the username was taken in the meantime.
  Future<void> createProfile(PlayerProfile profile, {required String? email});

  /// Updates editable fields. Username and stats are not changed here.
  Future<void> updateProfile(PlayerProfile profile);

  /// Uploads a profile photo and returns its download URL.
  Future<String> uploadProfilePhoto(String uid, Uint8List bytes);
}
