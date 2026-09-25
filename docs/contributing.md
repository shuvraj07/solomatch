# Contributing

## Workflow

1. Branch from `main`: `feat/<area>-<short-name>` or `fix/<area>-<short-name>`.
2. Keep PRs to one feature or fix.
3. Before pushing:
   ```sh
   dart format lib test
   flutter analyze          # must report "No issues found!"
   flutter test
   ```
4. Use [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat(matches): add match creation
   feat(requests): add join request
   fix(matches): prevent roster overbooking
   docs(realtime): explain roster listeners
   test(requests): cover concurrent accept
   ```
   Scopes match feature folder names (`auth`, `matches`, `match_requests`,
   `chat`, ...) or `app`, `core`, `functions`, `rules`.

## Adding a feature

1. Create `lib/features/<name>/{domain,data,presentation}/`.
2. **domain/** — entities (Freezed) and a repository interface:
   ```dart
   abstract interface class FavoritesRepository {
     Stream<List<Favorite>> watchFavorites(String userId);
     Future<void> add(Favorite favorite);
   }
   ```
3. **data/** — `FirestoreFavoritesRepository implements FavoritesRepository`,
   and a provider:
   ```dart
   final favoritesRepositoryProvider = Provider<FavoritesRepository>(
     (ref) => FirestoreFavoritesRepository(ref.watch(firestoreProvider)),
   );
   ```
4. **presentation/** — screens that `ref.watch` stream providers. No Firebase
   imports here.
5. Add routes to `AppRoutes` and `app_router.dart`.
6. Open up access in `firestore.rules` and add rules tests.
7. Add unit tests for domain logic, widget tests for screens using a fake
   repository, and update the docs.

## Code style

- Small files, one public widget or class per file where practical.
- Import `package:material_ui/material_ui.dart` for Material.
- Use `AppSpacing`, `AppRadius`, `AppColors` and the theme instead of magic numbers.
- Map Firebase exceptions to `AppFailure` subclasses in the data layer.
- Generated files (`*.g.dart`, `*.freezed.dart`) are committed so a fresh clone
  builds; rerun `dart run build_runner build --delete-conflicting-outputs`
  after changing a model.
