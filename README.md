# SoloMatch ⚽

Find local football matches and fill your team in real time.

**Organizer posts a match → players discover it → players request to join →
organizer accepts or rejects → the roster updates live on every device.**

Flutter (Android first) + Firebase (Auth, Firestore, Functions, Storage, FCM,
Crashlytics, Analytics), Riverpod, GoRouter, Freezed.

## Quick start

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Freezed / JSON codegen
flutter test
flutter run                                                 # needs Firebase config, see below
```

Without Firebase config the app starts on a "Firebase is not configured"
screen instead of crashing. Follow [docs/firebase-setup.md](docs/firebase-setup.md).

To run against the local Firebase Emulator Suite:

```sh
firebase emulators:start
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

## Documentation

| Doc | What's in it |
|---|---|
| [architecture.md](docs/architecture.md) | Layers, folder layout, how data flows, key decisions |
| [firebase-setup.md](docs/firebase-setup.md) | Creating the Firebase project and connecting the app |
| [testing.md](docs/testing.md) | Test layout and how to run each kind of test |
| [contributing.md](docs/contributing.md) | Branching, commits, adding a new feature |
| [authentication.md](docs/authentication.md) | Sign-in methods, session and redirects, onboarding |
| [firestore-schema.md](docs/firestore-schema.md) | Collections, fields, security rules |

| [realtime.md](docs/realtime.md) | Live data flow, the join flow end to end, why rosters can't overbook |

The Google Maps doc is added with the phase that introduces maps.

Cloud Functions and security-rules tests (need Java and the Firebase CLI):

```sh
cd functions && npm install
npm run test:functions   # accept/reject/leave incl. concurrent-accept race tests
npm run test:rules       # Firestore security rules
```

## Status

| Phase | Scope | State |
|---|---|---|
| 0 | Foundation: theme, navigation shell, Firebase bootstrap, emulator config | ✅ |
| 1 | Auth + onboarding (email, Google, forgot password, profile setup) | ✅ |
| 2 | Matches core (create flow, drafts, live match details, upcoming list) | ✅ |
| 3 | Maps + discovery + recommendations | ⏳ |
| 4 | Join requests + realtime roster (server-enforced capacity) | ✅ |
| 5 | Notifications + reminders | ⏳ |
| 6 | Chat | ⏳ |
| 7 | My Matches + player profiles | ⏳ |
| 8 | Favorites + football catalog | ⏳ |
| 9 | Reviews, safety, settings | ⏳ |
| 10 | Hardening, integration tests, CI | ⏳ |
