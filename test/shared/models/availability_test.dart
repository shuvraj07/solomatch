import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/shared/models/availability.dart';

void main() {
  test('toggle adds and removes slots', () {
    final a = const Availability().toggle(6, TimeBand.evening);
    expect(a.contains(6, TimeBand.evening), isTrue);
    expect(a.toggle(6, TimeBand.evening).isEmpty, isTrue);
  });

  test('round-trips through stored strings and skips junk', () {
    final a = const Availability()
        .toggle(6, TimeBand.evening)
        .toggle(1, TimeBand.morning);
    expect(a.toStrings(), ['1.morning', '6.evening']);
    expect(Availability.fromStrings(a.toStrings()), a);
    expect(
      Availability.fromStrings(['9.evening', 'x', '2.night']).isEmpty,
      isTrue,
    );
  });

  test('covers checks weekday and time band of a match start', () {
    final a = const Availability().toggle(DateTime.saturday, TimeBand.evening);
    expect(a.covers(DateTime(2026, 9, 26, 18)), isTrue); // Saturday 6 PM
    expect(a.covers(DateTime(2026, 9, 26, 9)), isFalse); // Saturday 9 AM
    expect(a.covers(DateTime(2026, 9, 27, 18)), isFalse); // Sunday
  });
}
