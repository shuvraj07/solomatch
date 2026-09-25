import 'package:intl/intl.dart';

/// Display formatting shared by match cards, details and the create flow.
abstract final class Formatters {
  /// "Sat, 28 Sep"
  static String shortDate(DateTime d) => DateFormat('EEE, d MMM').format(d);

  /// "Saturday, 28 September 2026"
  static String longDate(DateTime d) => DateFormat('EEEE, d MMMM y').format(d);

  /// "6:00 PM"
  static String time(DateTime d) => DateFormat.jm().format(d);

  /// "6:00 PM – 8:00 PM"
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  /// Minutes after midnight → "6:00 PM".
  static String minutesOfDay(int minutes) =>
      time(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));

  /// "1 h 30 min", "2 h", "45 min"
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h $m min';
  }
}
