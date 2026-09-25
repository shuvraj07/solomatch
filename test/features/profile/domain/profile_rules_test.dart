import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/features/profile/domain/profile_rules.dart';

void main() {
  group('username', () {
    test('normalizes to lowercase', () {
      expect(ProfileRules.normalizeUsername('  Raj_10 '), 'raj_10');
      expect(ProfileRules.validateUsername('Raj_10'), isNull);
    });

    test('rejects bad lengths and characters', () {
      expect(ProfileRules.validateUsername(''), isNotNull);
      expect(ProfileRules.validateUsername('ab'), isNotNull);
      expect(ProfileRules.validateUsername('a' * 21), isNotNull);
      expect(ProfileRules.validateUsername('raj shrestha'), isNotNull);
      expect(ProfileRules.validateUsername('raj!'), isNotNull);
    });
  });

  group('age', () {
    final today = DateTime(2026, 9, 25);

    test('counts birthdays exactly', () {
      expect(ProfileRules.ageOn(DateTime(2010, 9, 25), today), 16);
      expect(ProfileRules.ageOn(DateTime(2010, 9, 26), today), 15);
    });

    test('requires 16+', () {
      expect(
        ProfileRules.validateDateOfBirth(DateTime(2010, 9, 25), today: today),
        isNull,
      );
      expect(
        ProfileRules.validateDateOfBirth(DateTime(2010, 9, 26), today: today),
        isNotNull,
      );
      expect(ProfileRules.validateDateOfBirth(null), isNotNull);
    });
  });
}
