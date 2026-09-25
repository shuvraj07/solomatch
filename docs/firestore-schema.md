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

### `users/{uid}/devices/{token}`

`{platform, updatedAt}`: the FCM tokens of this user's phones. Only the owner
can read or write them. The server deletes dead ones.

### `users/{uid}/notifications/{id}` 🔒

`{type, title, body, matchId, read, createdAt}`: the in-app inbox, written only
by Cloud Functions. The owner can read it and flip `read` to true. See
[notifications.md](notifications.md).

Later phases add notification preferences, blocks and favorites.

## `matches/{matchId}`: published matches

Readable by any signed-in user. Created by the `publishDraft` Cloud Function
from the organizer's saved draft. The function re-validates the draft, puts
any pre-confirmed players on the roster, and deletes the draft, all in one
transaction. After that, the organizer can only edit descriptive text or
cancel. Roster counts and status belong to the server.

| Field | Type | Notes |
|---|---|---|
| `organizer` | map | `{uid, name, username, photoUrl}`. `username` must match the organizer's `players` doc |
| `title` / `searchTitle` | string | 3–80 chars; `searchTitle` = lowercase |
| `venue` | map | `{name, address, city, placeId, lat, lng}`. Coordinates are null until the map picker (Phase 3) |
| `startAt`, `endAt` | timestamp | Must start in the future; 30 min – 6 h long |
| `format` | string | `fiveASide` \| `sevenASide` \| `nineASide` \| `elevenASide` |
| `maxPlayers` | int | 2–30 |
| `currentPlayers` 🔒 | int | Players on the roster plus guests. Starts at the number of pre-confirmed players |
| `guestCount` 🔒 | int | Confirmed friends without an account (counted, not on the roster) |
| `spotsRemaining` 🔒 | int | `maxPlayers − currentPlayers`, kept for queries/sorting |
| `slots` 🔒 (filled) | map | `{gk, def, mid, fwd, any}` → `{needed, filled}`. The `needed` values add up to `maxPlayers` |
| `skillLevel` | string | `beginner` \| `intermediate` \| `advanced` \| `any` |
| `price` | map | `{amount (int NPR), currency: 'NPR', isFree}` |
| `isIndoor` | bool | |
| `description`, `rules` | string | ≤ 1000 chars each |
| `photos` | string[] | ≤ 5 Storage URLs under `match_photos/{organizerUid}/{matchId}/` |
| `status` | string | `published` → `filling` → `full` → `started` → `completed`, or `cancelled`. The client may only set `cancelled`. `started` and `completed` are set by the scheduled `advanceMatchLifecycle` function |
| `completedAt` 🔒, `votingClosesAt` 🔒 | timestamp | Set on completion; `votingClosesAt` = `endAt` + 24 h |
| `report` 🔒 | map | `{players: {uid: {goals, assists, yellowCards (0–2), redCard}}, submittedAt, updatedAt}`, written by the `saveMatchReport` function |
| `remindersSent` 🔒 | map | `{h24, h2, m30}` flags, so each kick-off reminder goes out once |
| `motmClosed` 🔒, `motm` 🔒 | bool, map | `motm = {winners: [{uid, name, username, photoUrl}], votes, totalVotes}`. Several winners means a tie |
| `createdAt`, `updatedAt` | timestamp | |

Indexes: `(organizer.uid, startAt DESC)` for "My matches → Created",
`(status, startAt)` for the upcoming list and kick-off,
`(status, endAt)` for completion, and `(status, motmClosed, votingClosesAt)`
for closing MOTM voting.

## `matches/{matchId}/requests/{playerId}`: join requests

The document ID is the player's uid, so each player has at most one request
per match. The player and the match organizer can read it.

| Field | Type | Notes |
|---|---|---|
| `status` | string | `pending` → `accepted` \| `rejected` (server), `cancelled` (player withdrew or left), or `expired` (still pending at kick-off; server) |
| `player` | map | Player card: `uid, name, username, photoUrl, primaryPosition, secondaryPositions, skillLevel, ratingAvg, ratingCount, gamesPlayed`. The rules check it matches `players/{uid}` |
| `preferredGroup` | string | `gk` \| `def` \| `mid` \| `fwd` \| `any` |
| `message` | string | ≤ 200 chars |
| `match` | map | `{title, startAt, venueName}`, a snapshot for "My requests" lists |
| `assignedGroup` 🔒 | string | Slot given on accept |
| `createdAt`, `updatedAt`, `decidedAt` 🔒, `leftAt` 🔒 | timestamp | |

Client writes: create a `pending` request (not your own match; the match must
be open and not started), withdraw `pending` → `cancelled`, and request again
from `cancelled`. `rejected` is final. Accept and reject happen only in Cloud
Functions.

Indexes: `(status ASC, createdAt ASC)` for the organizer's pending list, and a
**collection-group** index `(player.uid ASC, match.startAt DESC)` for "My
matches". The collection-group rule returns only your own requests:
`resource.data.player.uid == auth.uid`.

## `matches/{matchId}/roster/{playerId}`: accepted players 🔒

`{player (card), group, joinedAt}`. Readable by signed-in users. Written only
by the `acceptJoinRequest` and `leaveJoinedMatch` Cloud Functions, in the same
transaction that updates the match counters.

## `matches/{matchId}/motm_votes/{voterId}`: Man of the Match votes

`{nomineeId, votedAt}`. One vote per voter (the doc ID), and it can be changed
until `votingClosesAt`. Voters are roster players plus the organizer;
nominees must be on the roster and can't be yourself. Votes are private to
the voter. The server tallies them when voting closes.

## `players/{uid}.stats` 🔒: career totals

`gamesPlayed`, `gamesOrganized` (on completion), `goals`, `assists`,
`yellowCards`, `redCards` (from reports; edits apply only the difference) and
`motmAwards` (when voting closes), and `ratingAvg`, `ratingCount`, `ratingSum`
(from reviews).

## `conversations/{id}`: chats (created only by Cloud Functions)

- `match_{matchId}`: **group chat** for the organizer plus the roster. The
  `onRosterWritten` trigger adds and removes members as players join or leave.
- `dm_{matchId}_{playerId}`: **private chat** between organizer and player,
  opened with the `openDirectConversation` callable. Allowed once the player
  has a join request.

| Field | Type | Notes |
|---|---|---|
| `type` | string | `group` \| `direct` |
| `matchId`, `title` | string | Title = match title |
| `participantIds` | string[] | Members. Reads require `auth.uid in participantIds` |
| `participants` | map | `{uid: {name, photoUrl}}` |
| `lastMessage` 🔒, `lastMessageAt` 🔒 | map, timestamp | Set by `onChatMessageCreated` |
| `readAt` | map | `{uid: timestamp}`. Each member can set only their own entry, to "now" |

Index: `participantIds` (array-contains) + `lastMessageAt DESC`.

### `conversations/{id}/messages/{messageId}`

`{senderId, text | imageUrl, sentAt}`. Only members can read. Members can post
as themselves: text of 1–2000 chars, or one photo (uploaded to
`chat_images/{uid}/{conversationId}/`). Messages can't be edited or deleted.
Each new message pushes a notification to the other members (push only, not
the 🔔 inbox).

## `reviews/{matchId}_{reviewerId}_{revieweeId}`: ratings

`{matchId, reviewerId, revieweeId, rating (1–5), comment (≤ 300), reviewer
{name, photoUrl}, matchTitle, createdAt, counted 🔒}`. Readable by anyone
signed in. **Create-only**: the deterministic ID means one review per pair per
match. Both people must have been at the match (roster or organizer), within
7 days of `endAt`. The `onReviewCreated` function adds the review to
`players/{revieweeId}.stats` (`ratingCount`, `ratingSum`, `ratingAvg`),
marks it `counted` (so it's idempotent) and notifies the player.

Index: `(revieweeId ASC, createdAt DESC)`.

## `match_drafts/{draftId}`: unfinished matches

Private to the organizer (`organizerId == auth.uid`). Same shape as the create
form: `title`, `venue`, `date` (UTC midnight), `startMinutes`/`endMinutes`
(minutes after midnight), `format`, `maxPlayers`, `neededPositions`
(`{gk: 1, ...}`), `skillLevel`, `priceAmount`, `isIndoor`, `description`,
`rules`, `photos`, `updatedAt`. The draft ID becomes the match ID on publish.

Pre-confirmed players ("Your players" step):
- `organizerPlaying` (bool) and `organizerGroup`: the organizer takes a spot.
- `lineup`: `[{uid, name, username, photoUrl, primaryPosition, group}]`, SoloMatch
  users who are already coming. On publish each gets a roster entry and an
  `accepted` request (`addedByOrganizer: true`), so the match appears in their
  My Matches and they can **Leave**. They're notified with `added_to_match`.
- `guestCount`: friends who aren't on SoloMatch.
- `startAt` / `endAt`: absolute times computed on the organizer's phone. The
  server uses these rather than re-deriving them from the date and minutes.

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
- Across all matches, a player can list only their own join requests.
- Reviews: only people who were at the match, only about someone who was
  there, once, within 7 days, never edited; the reviewer name must be real.
- Chats: only members can read; you can post only as yourself; conversations
  can't be created by clients; you can move only your own read marker.
- Device tokens are owner-only. The inbox can't be written by clients except to
  mark items read, so nobody can fake notifications.
- Join requests can only be created by the player themselves, with a player
  card matching their real profile (no faked rating or games played), on an
  open, not-started match they don't organize. Nobody can set `accepted` or
  `rejected` from a client, and the roster can't be written from a client.
