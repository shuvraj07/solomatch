# Firestore schema

Collections are added as each feature lands. Field names here are the
contract between the app (mappers in `features/*/data/`), Cloud Functions and
`firestore.rules`. Change all three together.

Conventions:
- Enums are stored by Dart `name` (`centralMidfielder`, `intermediate`).
- Timestamps are Firestore `Timestamp`s. `createdAt` and `updatedAt` are always
  `serverTimestamp()`, and the rules check them against `request.time`.
- Server-only fields are marked 🔒. Clients can read them, but the rules reject
  client writes.

## `players/{uid}`: public football profile

Readable by any signed-in user. Written by the owner.

| Field | Type | Notes |
|---|---|---|
| `fullName` | string | 2–60 chars |
| `searchName` | string | `fullName.lower()`, for prefix search |
| `username` | string | Set once at creation; must match `usernames/{username}` |
| `photoUrl` | string \| null | Storage download URL |
| `dateOfBirth` | timestamp | UTC midnight. The player must be 16+. Not shown publicly. |
| `city` | string | 1–60 chars |
| `bio` | string | ≤ 300 chars |
| `primaryPosition` | string | One of the 8 `Position` names |
| `secondaryPositions` | string[] | ≤ 3 |
| `skillLevel` | string | `beginner` \| `intermediate` \| `advanced` |
| `preferredFoot` | string | `right` \| `left` \| `both` |
| `heightCm` | int \| null | 120–230 |
| `yearsPlaying` | int | 0–60 |
| `languages` | string[] | ≤ 10 |
| `availability` | string[] | `"<weekday>.<band>"`, e.g. `"6.evening"` (1 = Mon). ≤ 21 |
| `stats` 🔒 | map | `gamesPlayed`, `gamesOrganized`, `ratingAvg`, `ratingCount`. Absent until the server sets it. |
| `createdAt`, `updatedAt` | timestamp | |

## `usernames/{username}`: uniqueness index

`{ uid }`. The document ID is the lowercase username (`^[a-z0-9_]{3,20}$`).
Created in the same transaction as the profile. It can never be updated or
deleted by clients. Anyone signed in can `get` one (the availability check);
listing is denied.

## `users/{uid}`: private account data

Only the owner can read or write it.

| Field | Type | Notes |
|---|---|---|
| `email` | string \| null | Must equal the auth token's email |
| `createdAt` | timestamp | |

Later phases add notification preferences, FCM device tokens
(`users/{uid}/devices`), blocks and favorites.

## Security

`firestore.rules` denies everything that isn't explicitly allowed. The tests are
in `functions/test/rules/` (`npm run test:rules`) and cover:

- A profile can only be created together with its username claim, and only by its owner.
- `stats` and `username` can't be written by clients after creation.
- Under-16 dates of birth and unknown positions are rejected.
- One username per player: a second claim is rejected once a profile exists.
- Private `users/{uid}` documents are owner-only, and `email` must match the token.
