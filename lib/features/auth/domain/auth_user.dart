import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// The signed-in account, independent of the auth provider used.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) = _AuthUser;
}
