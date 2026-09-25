import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_failure.dart';

/// Turns Firebase Auth error codes into messages safe to show users.
///
/// Sign-in deliberately does not reveal whether an email is registered.
AppFailure mapAuthException(FirebaseAuthException e) {
  final message = switch (e.code) {
    'invalid-email' => 'That email address looks wrong.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'INVALID_LOGIN_CREDENTIALS' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Choose a stronger password (at least 8 characters).',
    'account-exists-with-different-credential' =>
      'This email is registered with another sign-in method. '
          'Sign in that way first.',
    'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
    'network-request-failed' => 'No connection. Check your internet.',
    'operation-not-allowed' => 'This sign-in method is not enabled yet.',
    _ => 'Sign-in failed. Please try again.',
  };
  return e.code == 'network-request-failed'
      ? NetworkFailure(message)
      : AuthFailure(message);
}
