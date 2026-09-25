import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/auth/data/auth_error_mapper.dart';

AppFailure map(String code) =>
    mapAuthException(FirebaseAuthException(code: code));

void main() {
  test('wrong email and wrong password give the same message', () {
    final messages = {
      map('user-not-found').message,
      map('wrong-password').message,
      map('invalid-credential').message,
    };
    expect(messages, hasLength(1));
  });

  test('network errors become NetworkFailure', () {
    expect(map('network-request-failed'), isA<NetworkFailure>());
  });

  test('known codes get specific messages; unknown codes a generic one', () {
    expect(map('email-already-in-use').message, contains('already exists'));
    expect(map('something-new'), isA<AuthFailure>());
  });
}
