import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/features/matches/domain/create_match_step.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_validator.dart';
import 'package:solomatch/shared/models/position_group.dart';
import 'package:solomatch/shared/models/venue.dart';

import '../../../fakes/match_test_data.dart';

String? check(CreateMatchStep step, MatchDraft d) =>
    MatchValidator.validateStep(step, d, now: testNow);

void main() {
  test('a complete draft is publishable', () {
    expect(
      MatchValidator.validateForPublish(completeDraft(), now: testNow),
      isEmpty,
    );
    expect(
      MatchValidator.firstInvalidStep(completeDraft(), now: testNow),
      isNull,
    );
  });

  test('title length', () {
    expect(
      check(CreateMatchStep.title, completeDraft().copyWith(title: ' ab ')),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.title, completeDraft().copyWith(title: 'x' * 81)),
      isNotNull,
    );
  });

  test('venue needs a name and city', () {
    final d = completeDraft();
    expect(check(CreateMatchStep.venue, d.copyWith(venue: null)), isNotNull);
    expect(
      check(
        CreateMatchStep.venue,
        d.copyWith(
          venue: const Venue(name: 'Pitch', city: ' '),
        ),
      ),
      isNotNull,
    );
  });

  test('map location is optional for now', () {
    expect(check(CreateMatchStep.location, completeDraft()), isNull);
  });

  test('date cannot be in the past; today is fine', () {
    final d = completeDraft();
    expect(
      check(CreateMatchStep.date, d.copyWith(date: DateTime(2026, 9, 24))),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.date, d.copyWith(date: DateTime(2026, 9, 25))),
      isNull,
    );
  });

  test('kick-off must be at least 30 minutes ahead', () {
    final today = completeDraft().copyWith(date: DateTime(2026, 9, 25));
    expect(
      check(
        CreateMatchStep.startTime,
        today.copyWith(startMinutes: 10 * 60 + 15),
      ),
      isNotNull,
    );
    expect(
      check(
        CreateMatchStep.startTime,
        today.copyWith(startMinutes: 10 * 60 + 30),
      ),
      isNull,
    );
  });

  test('duration between 30 minutes and 6 hours', () {
    final d = completeDraft();
    expect(
      check(CreateMatchStep.endTime, d.copyWith(endMinutes: 18 * 60 + 20)),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.endTime, d.copyWith(endMinutes: 18 * 60 + 30)),
      isNull,
    );
    expect(
      check(CreateMatchStep.endTime, d.copyWith(endMinutes: 1)),
      isNotNull,
    );
  });

  test('player count and positions', () {
    final d = completeDraft();
    expect(
      check(CreateMatchStep.maxPlayers, d.copyWith(maxPlayers: 1)),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.maxPlayers, d.copyWith(maxPlayers: 31)),
      isNotNull,
    );
    expect(
      check(
        CreateMatchStep.positions,
        d.copyWith(
          maxPlayers: 4,
          neededPositions: const {PositionGroup.def: 5},
        ),
      ),
      isNotNull,
    );
  });

  test('price, text and photo limits', () {
    final d = completeDraft();
    expect(
      check(CreateMatchStep.price, d.copyWith(priceAmount: 200000)),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.description, d.copyWith(description: 'x' * 1001)),
      isNotNull,
    );
    expect(
      check(CreateMatchStep.photos, d.copyWith(photos: List.filled(6, 'u'))),
      isNotNull,
    );
  });

  test('firstInvalidStep points at the earliest problem', () {
    final d = completeDraft().copyWith(title: '', startMinutes: null);
    expect(
      MatchValidator.firstInvalidStep(d, now: testNow),
      CreateMatchStep.title,
    );
    expect(MatchValidator.validateForPublish(d, now: testNow), hasLength(3));
  });
}
