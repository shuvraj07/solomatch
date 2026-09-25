import 'package:material_ui/material_ui.dart';

/// Brand and semantic colors. Widgets should prefer `Theme.of(context)`
/// and only reach for these for football-specific meaning (positions, status).
abstract final class AppColors {
  /// Pitch green: the brand seed color.
  static const pitch = Color(0xFF0E9F5B);

  /// Energetic accent used for highlights and the Create Match button.
  static const volt = Color(0xFFC6F432);

  /// From the logo.
  static const brandBlue = Color(0xFF1E5BD6);
  static const brandOrange = Color(0xFFFF7A1A);

  static const goalkeeper = Color(0xFFF2A516);
  static const defender = Color(0xFF2F6FED);
  static const midfielder = Color(0xFF12A36B);
  static const forward = Color(0xFFE5484D);
  static const anyPosition = Color(0xFF7C66DC);

  static const statusOpen = Color(0xFF12A36B);
  static const statusFilling = Color(0xFFF2A516);
  static const statusFull = Color(0xFFE5484D);
  static const statusNeutral = Color(0xFF7A8290);
  static const live = Color(0xFFE5484D);
}
