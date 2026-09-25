# Testing

| Kind | Location | Run with | Covers |
|---|---|---|---|
| Unit | `test/**` | `flutter test` | Domain logic: models, validators, `MatchingService` |
| Widget | `test/**` | `flutter test` | Screens rendered with fake repositories |
| Integration | `integration_test/` | `flutter test integration_test` (device + emulators) | End-to-end flows |
| Cloud Functions | `functions/test/` | `npm test` inside `functions/` (Emulator Suite) | Accept/reject transactions, **capacity race conditions** |
| Security rules | `functions/test/rules/` | `npm run test:rules` | Who can read and write what |

The `test/` folder mirrors `lib/`. For example, `lib/shared/models/price.dart`
is tested in `test/shared/models/price_test.dart`.

## Faking the backend in widget tests

Override the repository provider rather than Firebase itself:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      matchRepositoryProvider.overrideWithValue(FakeMatchRepository()),
    ],
    child: const SoloMatchApp(),
  ),
);
```

In-memory fakes live in `test/fakes/`. To test a realtime UI, a fake exposes
a `StreamController`; the test pushes a new value into it and checks that the
screen updated.

## Capacity guarantee

The rule that a match can never go over `maxPlayers` is enforced on the server,
so it is tested against the Firestore emulator. The test fires concurrent
`acceptJoinRequest` calls at a match with one slot left, then checks that
exactly one succeeds and the roster size equals `maxPlayers`.
