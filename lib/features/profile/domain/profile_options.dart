/// Choice lists shown when editing a profile. Kept here (not in widgets) so
/// they can later move to remote config without touching UI code.
abstract final class ProfileOptions {
  static const languages = [
    'Nepali',
    'English',
    'Hindi',
    'Maithili',
    'Newari',
    'Bhojpuri',
    'Tamang',
  ];

  static const defaultLanguages = ['Nepali'];
}
