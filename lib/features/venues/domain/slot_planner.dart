import 'venue_models.dart';

/// What the owner fills in on "Add slots".
class SlotPlan {
  const SlotPlan({
    required this.firstDay,
    required this.fromMinutes,
    required this.toMinutes,
    this.lengthMinutes = 60,
    this.price = 0,
    this.days = 1,
    this.weekdays = const {1, 2, 3, 4, 5, 6, 7},
  });

  /// Calendar day to start from (time ignored).
  final DateTime firstDay;

  /// Opening and closing time, minutes after midnight. [toMinutes] may be
  /// 24 * 60 (midnight).
  final int fromMinutes;
  final int toMinutes;

  /// Length of each slot: 60, 90 or 120 minutes.
  final int lengthMinutes;
  final int price;

  /// How many days, starting at [firstDay], to repeat for.
  final int days;

  /// Only these weekdays (1 = Monday … 7 = Sunday).
  final Set<int> weekdays;
}

/// Turns a [SlotPlan] into individual slots. Pure, so it's unit-tested.
abstract final class SlotPlanner {
  /// Firestore batch limit, with headroom.
  static const maxSlots = 400;

  /// Slots for [plan], skipping any that start before [now] or overlap an
  /// [existing] slot. Throws [ArgumentError] with a user-facing message if
  /// the plan makes no sense.
  static List<NewSlot> plan(
    SlotPlan plan, {
    required DateTime now,
    Iterable<VenueSlot> existing = const [],
  }) {
    if (plan.toMinutes - plan.fromMinutes < plan.lengthMinutes) {
      throw ArgumentError(
        'Closing time must be at least one slot after opening',
      );
    }
    if (plan.lengthMinutes < 30 || plan.lengthMinutes > 360) {
      throw ArgumentError('Slots must be 30 minutes to 6 hours long');
    }
    final taken = existing.toList();
    final slots = <NewSlot>[];
    final first = DateTime(
      plan.firstDay.year,
      plan.firstDay.month,
      plan.firstDay.day,
    );
    for (var d = 0; d < plan.days; d++) {
      final day = DateTime(first.year, first.month, first.day + d);
      if (!plan.weekdays.contains(day.weekday)) continue;
      for (
        var m = plan.fromMinutes;
        m + plan.lengthMinutes <= plan.toMinutes;
        m += plan.lengthMinutes
      ) {
        final start = day.add(Duration(minutes: m));
        final end = start.add(Duration(minutes: plan.lengthMinutes));
        if (!start.isAfter(now)) continue;
        if (taken.any((s) => s.overlaps(start, end))) continue;
        slots.add((startAt: start, endAt: end, price: plan.price));
        if (slots.length > maxSlots) {
          throw ArgumentError(
            'That’s more than $maxSlots slots. Add fewer days',
          );
        }
      }
    }
    return slots;
  }
}
