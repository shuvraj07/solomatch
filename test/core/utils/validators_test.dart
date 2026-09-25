import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/core/utils/validators.dart';

void main() {
  test('email', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('raj'), isNotNull);
    expect(Validators.email('raj@mail'), isNotNull);
    expect(Validators.email(' raj@mail.com '), isNull);
  });

  test('new password needs 8+ characters', () {
    expect(Validators.newPassword(''), isNotNull);
    expect(Validators.newPassword('1234567'), isNotNull);
    expect(Validators.newPassword('12345678'), isNull);
  });

  test('sign-in password only needs to be present', () {
    expect(Validators.requiredPassword(''), isNotNull);
    expect(Validators.requiredPassword('x'), isNull);
  });
}
