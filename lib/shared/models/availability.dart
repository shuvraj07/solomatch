/// Part of the day a player is usually free.
enum TimeBand {
  morning('Morning', 'before 12'),
  afternoon('Afternoon', '12–5'),
  evening('Evening', 'after 5');

  const TimeBand(this.label, this.hint);

  final String label;
  final String hint;

  /// Band a match start time falls in (local time).
  static TimeBand of(DateTime time) => time.hour < 12
      ? morning
      : time.hour < 17
      ? afternoon
      : evening;
}

/// A day of the week plus a [TimeBand], e.g. Saturday evening.
typedef AvailabilitySlot = ({int weekday, TimeBand band});

/// When a player is usually free to play. Weekdays follow [DateTime.weekday]
/// (1 = Monday … 7 = Sunday).
///
/// Stored as a list of `"<weekday>.<band>"` strings, e.g. `["6.evening"]`.
class Availability {
  const Availability([this.slots = const {}]);

  factory Availability.fromStrings(Iterable<String> values) =>
      Availability({for (final value in values) ?_parse(value)});

  final Set<AvailabilitySlot> slots;

  bool get isEmpty => slots.isEmpty;

  bool contains(int weekday, TimeBand band) =>
      slots.contains((weekday: weekday, band: band));

  /// Whether the player is usually free when a match starting at [start] is on.
  bool covers(DateTime start) => contains(start.weekday, TimeBand.of(start));

  Availability toggle(int weekday, TimeBand band) {
    final slot = (weekday: weekday, band: band);
    final next = {...slots};
    if (!next.remove(slot)) next.add(slot);
    return Availability(next);
  }

  List<String> toStrings() =>
      [for (final s in slots) '${s.weekday}.${s.band.name}']..sort();

  static AvailabilitySlot? _parse(String value) {
    final parts = value.split('.');
    if (parts.length != 2) return null;
    final weekday = int.tryParse(parts[0]);
    final band = TimeBand.values.asNameMap()[parts[1]];
    if (weekday == null || weekday < 1 || weekday > 7 || band == null) {
      return null;
    }
    return (weekday: weekday, band: band);
  }

  @override
  bool operator ==(Object other) =>
      other is Availability &&
      other.slots.length == slots.length &&
      other.slots.containsAll(slots);

  @override
  int get hashCode => Object.hashAllUnordered(slots);
}
