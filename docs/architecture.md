# Architecture

## Principles

1. **Feature-first.** Code lives with the feature it serves (`lib/features/<feature>/`).
   A new engineer should be able to own one feature folder end to end.
2. **Layered inside each feature.**
   - `domain/` — plain Dart: entities, repository *interfaces*, business rules
     (validators, `MatchingService`). No Flutter, no Firebase imports.
   - `data/` — Firebase implementations of the domain interfaces, plus mapping
     between Firestore documents and entities. The **only** place that imports
     `cloud_firestore`, `firebase_auth`, etc.
   - `presentation/` — screens, widgets, Riverpod controllers.
3. **Widgets never query Firestore.** They `ref.watch` providers; providers call
   repositories.
4. **The server decides anything contested.** Accepting players, capacity,
   match status, counters, notifications and ratings are written by Cloud
   Functions inside transactions. Security rules stop clients from writing
   those fields. Client-side checks exist only for fast feedback.
5. **Realtime by default.** Repositories expose `Stream`s backed by Firestore
   snapshot listeners; the UI rebuilds when data changes. No pull-to-refresh
   as the source of truth.

## Folder layout

```
lib/
  main.dart               entry point → bootstrap()
  bootstrap.dart          Firebase init, emulators, Crashlytics hooks
  app/
    app.dart              MaterialApp.router
    config/env.dart       --dart-define settings
    providers/            Firebase SDK instances (data layer only)
    router/               GoRouter + route constants
    shell/                bottom navigation shell
    theme/                colors, spacing, ThemeData
  core/                   feature-agnostic: errors, constants, utils, widgets
  shared/
    models/               football vocabulary used across features
                          (Position, PositionGroup, SkillLevel, MatchFormat, Price)
    widgets/              design-system widgets (PositionBadge, ...)
  features/<feature>/{domain,data,presentation}
functions/                Cloud Functions (TypeScript) — added in Phase 4
firestore.rules           security rules (deny-all baseline until features open access)
docs/
test/                     mirrors lib/
```

Cross-feature rule: a feature may import another feature's `domain/`, and
anything in `core/` or `shared/`. It must not import another feature's
`presentation/` or `data/`.

## Data flow

```
Widget ──watch──▶ Provider ──calls──▶ Repository (interface, domain/)
                                         ▲
                                         │ implements
                              FirebaseXRepository (data/) ──▶ Firestore / Functions
```

Repository providers are the seam for tests: override
`matchRepositoryProvider` (etc.) with an in-memory fake in `ProviderScope`.

## Football vocabulary

- **Position** (8 values) is what a *player* plays: Goalkeeper, Center Back,
  Full Back, Defensive/Central/Attacking Midfielder, Winger, Striker.
- **PositionGroup** (GK, DEF, MID, FWD, ANY) is what a *match* has slots for.
  Every `Position` maps to one group. `ANY` slots are the remainder:
  `maxPlayers − (GK + DEF + MID + FWD)`.
- Enums are stored in Firestore by their Dart `name` (`centralMidfielder`,
  `fiveASide`). Renaming an enum value is a data migration.

## Navigation

`StatefulShellRoute.indexedStack` keeps each tab's stack alive:
Home, Discover, Messages, Profile. **Create Match** is a raised centre button
that pushes a full-screen route above the shell. All paths are in
`AppRoutes`; never hard-code route strings in widgets.

## Material library

Flutter 3.44+ moved Material into the `material_ui` package. Import
`package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.

## Configuration

| `--dart-define` | Default | Purpose |
|---|---|---|
| `USE_FIREBASE_EMULATORS` | `false` | Use the local Emulator Suite |
| `EMULATOR_HOST` | `10.0.2.2` | Emulator host (Android emulator → host machine) |
| `FUNCTIONS_REGION` | `asia-south1` | Region of the Cloud Functions |

## Room to grow

The following are out of scope for now, but the layout already has a place for
them: teams/leagues (`features/teams`), statistics and results (new
subcollections under `matches/{id}`), paid matches (`Price` already exists),
an admin dashboard (custom claims + a web target sharing `domain/`), and AI
recommendations (replace the `MatchingService` implementation).
