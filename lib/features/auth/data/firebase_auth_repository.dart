import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'auth_error_mapper.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.toAuthUser());

  @override
  AuthUser? get currentUser => _auth.currentUser?.toAuthUser();

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) => _guard(
    () => _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> signInWithGoogle() async {
    // google_sign_in 7 requires exactly one initialize() before use. On
    // Android the server client ID comes from google-services.json.
    await (_googleInit ??= _googleSignIn.initialize());

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.clientConfigurationError
            ? 'Google sign-in is not configured for this build.'
            : 'Google sign-in failed. Please try again.',
      );
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthFailure('Google did not return a sign-in token.');
    }
    await _guard(
      () => _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      ),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() async {
    if (_googleInit != null) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }
}

extension on User {
  AuthUser toAuthUser() => AuthUser(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoURL,
  );
}
