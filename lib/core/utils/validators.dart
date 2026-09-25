/// Form validators returning an error message, or null when valid.
abstract final class Validators {
  static const minPasswordLength = 8;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!_email.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  /// Sign-in only checks presence; strength rules apply at sign-up.
  static String? requiredPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Enter your password' : null;

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Choose a password';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  static String? required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;
}
