import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/player_profile.dart';
import '../domain/profile_repository.dart';
import '../domain/profile_rules.dart';
import 'player_profile_mapper.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _player(String uid) =>
      _db.collection('players').doc(uid);

  DocumentReference<Map<String, dynamic>> _username(String username) =>
      _db.collection('usernames').doc(username);

  @override
  Stream<PlayerProfile?> watchProfile(String uid) =>
      _player(uid).snapshots().map((snap) {
        final data = snap.data();
        return data == null
            ? null
            : PlayerProfileMapper.fromFirestore(snap.id, data);
      });

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final snap = await _username(ProfileRules.normalizeUsername(username))
        .get();
    return !snap.exists;
  }

  @override
  Future<void> createProfile(
    PlayerProfile profile, {
    required String? email,
  }) async {
    final username = ProfileRules.normalizeUsername(profile.username);
    final now = FieldValue.serverTimestamp();

    try {
      await _db.runTransaction((tx) async {
        final claim = await tx.get(_username(username));
        if (claim.exists && claim.data()?['uid'] != profile.uid) {
          throw const ValidationFailure('That username was just taken.');
        }
        tx
          ..set(_username(username), {'uid': profile.uid})
          ..set(_player(profile.uid), {
            ...PlayerProfileMapper.editableFields(profile),
            'username': username,
            'createdAt': now,
            'updatedAt': now,
          })
          ..set(_db.collection('users').doc(profile.uid), {
            'email': email,
            'createdAt': now,
          }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    }
  }

  @override
  Future<void> updateProfile(PlayerProfile profile) async {
    try {
      await _player(profile.uid).update({
        ...PlayerProfileMapper.editableFields(profile),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    }
  }

  @override
  Future<String> uploadProfilePhoto(String uid, Uint8List bytes) async {
    try {
      final ref = _storage.ref('users/$uid/profile/avatar.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException {
      throw const UnknownFailure("Couldn't upload your photo. Try again.");
    }
  }
}

AppFailure _mapFirestoreException(FirebaseException e) => switch (e.code) {
  'permission-denied' => const PermissionFailure(),
  'unavailable' => const NetworkFailure(),
  'not-found' => const NotFoundFailure(),
  _ => const UnknownFailure(),
};
