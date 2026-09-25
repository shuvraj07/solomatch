/// Validation rules for player profiles, shared by onboarding and edit
/// screens. Keep in sync with the checks in firestore.rules.
abstract final class ProfileRules {
  /// Players meet strangers in person, so accounts are for 16+.
  static const minimumAge = 16;
  static const maxSecondaryPositions = 3;
  static const maxBioLength = 300;
  static const minHeightCm = 120;
  static const maxHeightCm = 230;

  static final _usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

  static String normalizeUsername(String value) => value.trim().toLowerCase();

  /// Returns an error message, or null if [value] is a valid username.
  static String? validateUsername(String? value) {
    final username = normalizeUsername(value ?? '');
    if (username.isEmpty) return 'Choose a username';
    if (!_usernamePattern.hasMatch(username)) {
      return '3–20 characters: letters, numbers and _';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'Enter your name';
    if (name.length > 60) return 'Name is too long';
    return null;
  }

  static String? validateDateOfBirth(DateTime? value, {DateTime? today}) {
    if (value == null) return 'Enter your date of birth';
    if (ageOn(value, today ?? DateTime.now()) < minimumAge) {
      return 'You must be at least $minimumAge to use SoloMatch';
    }
    return null;
  }

  static int ageOn(DateTime birth, DateTime today) {
    var age = today.year - birth.year;
    final hadBirthday =
        today.month > birth.month ||
        (today.month == birth.month && today.day >= birth.day);
    if (!hadBirthday) age--;
    return age;
  }
}
