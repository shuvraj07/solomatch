import 'auth_user.dart';

/// Authentication operations. Implementations throw [AuthFailure]
/// (see core/errors) with a user-presentable message.
abstract interface class AuthRepository {
  /// Emits the current user immediately, then on every sign-in or sign-out.
  /// Firebase persists the session, so this survives app restarts.
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Completes silently if the user dismisses the Google account picker.
  Future<void> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
