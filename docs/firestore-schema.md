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

## `matches/{matchId}`: published matches

Readable by any signed-in user. Created by the organizer, whose app writes the
document and deletes the draft in one batch. After that, the organizer can only
edit descriptive text or cancel. Roster counts and status belong to the server
(Phase 4).

| Field | Type | Notes |
|---|---|---|
| `organizer` | map | `{uid, name, username, photoUrl}`. `username` must match the organizer's `players` doc |
| `title` / `searchTitle` | string | 3–80 chars; `searchTitle` = lowercase |
| `venue` | map | `{name, address, city, placeId, lat, lng}`. Coordinates are null until the map picker (Phase 3) |
| `startAt`, `endAt` | timestamp | Must start in the future; 30 min – 6 h long |
| `format` | string | `fiveASide` \| `sevenASide` \| `nineASide` \| `elevenASide` |
| `maxPlayers` | int | 2–30 |
| `currentPlayers` 🔒 | int | Accepted players. Starts at 0 |
| `spotsRemaining` 🔒 | int | `maxPlayers − currentPlayers`, kept for queries/sorting |
| `slots` 🔒 (filled) | map | `{gk, def, mid, fwd, any}` → `{needed, filled}`. The `needed` values add up to `maxPlayers` |
| `skillLevel` | string | `beginner` \| `intermediate` \| `advanced` \| `any` |
| `price` | map | `{amount (int NPR), currency: 'NPR', isFree}` |
| `isIndoor` | bool | |
| `description`, `rules` | string | ≤ 1000 chars each |
| `photos` | string[] | ≤ 5 Storage URLs under `match_photos/{organizerUid}/{matchId}/` |
| `status` | string | `published` → `filling` → `full` → `started` → `completed`, or `cancelled`. The client may only set `cancelled` |
| `createdAt`, `updatedAt` | timestamp | |

Indexes: `(status ASC, startAt ASC)` for the upcoming-matches list.

## `match_drafts/{draftId}`: unfinished matches

Private to the organizer (`organizerId == auth.uid`). Same shape as the create
form: `title`, `venue`, `date` (UTC midnight), `startMinutes`/`endMinutes`
(minutes after midnight), `format`, `maxPlayers`, `neededPositions`
(`{gk: 1, ...}`), `skillLevel`, `priceAmount`, `isIndoor`, `description`,
`rules`, `photos`, `updatedAt`. The draft ID becomes the match ID on publish.

Index: `(organizerId ASC, updatedAt DESC)`.

## Security

`firestore.rules` denies everything that isn't explicitly allowed. The tests are
in `functions/test/rules/` (`npm run test:rules`) and cover:

- A profile can only be created together with its username claim, and only by its owner.
- `stats` and `username` can't be written by clients after creation.
- Under-16 dates of birth and unknown positions are rejected.
- One username per player: a second claim is rejected once a profile exists.
- Private `users/{uid}` documents are owner-only, and `email` must match the token.
- Matches can only be published by their organizer, with zero counters, valid
  slots that add up to `maxPlayers`, a future start and a sane duration.
- Organizers can't change capacity, counters or status (except cancel), and
  other players can't edit or cancel at all. Matches can't be deleted.
- Drafts are private to their organizer.
