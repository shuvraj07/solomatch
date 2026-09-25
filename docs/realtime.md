# Realtime architecture

SoloMatch never relies on pull-to-refresh. Every screen that shows shared
data listens to Firestore, so a change made on one phone appears on every
other phone within about a second.

## How data reaches the screen

```
Firestore doc/query ──snapshots()──▶ Repository Stream ──▶ StreamProvider ──▶ widget (ref.watch)
```

- Repositories return `Stream`s built on `snapshots()`. There are no
  one-off `get()`s for anything shown on screen.
- Providers are `StreamProvider.autoDispose(.family)`. The listener closes
  when the last widget watching it goes away.
- Widgets `ref.watch` the provider and rebuild when it emits.

| Provider | Source | Used by |
|---|---|---|
| `matchProvider(id)` | `matches/{id}` | Match details, requests screen header |
| `upcomingMatchesProvider` | `matches` where status listed, `startAt > now` | Home |
| `myRequestProvider(matchId)` | `matches/{id}/requests/{myUid}` | Match details button, "You're in! ⚽" |
| `pendingRequestsProvider(matchId)` | `requests` where `status == pending` | Organizer requests screen, badge |
| `rosterProvider(matchId)` | `matches/{id}/roster` | Player names on the roster card |
| `playerProfileProvider(uid)` | `players/{uid}` | Session and profile |

## The join flow, end to end

```
Player app                      Firestore / Functions                 Organizer app
──────────                      ─────────────────────                 ─────────────
Request to Join ──write──▶ requests/{uid} {pending}  ──snapshot──▶  new card appears, badge +1
                                                                       │ Accept
                           acceptJoinRequest (callable) ◀──────────────┘
                           ┌ transaction ───────────────────────────┐
                           │ read match + request                   │
                           │ check organizer, pending, capacity,    │
                           │   not started; pick position slot      │
                           │ write roster/{uid}                     │
                           │ request.status = accepted              │
                           │ match.currentPlayers + 1, slot filled  │
                           │ status → filling / full                │
                           └────────────────────────────────────────┘
"You're in! ⚽" ◀──snapshot── requests/{uid} {accepted}
7/10 → 8/10     ◀──snapshot── matches/{id}  ──snapshot──▶           7/10 → 8/10
Name on roster  ◀──snapshot── roster/{uid}   ──snapshot──▶           card disappears
```

Anyone else viewing the match sees 7/10 → 8/10 from the same `matches/{id}`
listener. When the last place is taken the status becomes `full`, and
"Request to Join" turns into "Match Full" for everyone at once.

## Why the roster can't overbook

- **Only the server writes the roster and the counters.** Security rules deny
  client writes to `roster/*`, and to `currentPlayers`, `slots.*.filled` and
  `status` (except the organizer cancelling).
- **Accept runs in a Firestore transaction.** If two accepts race, Firestore
  retries the loser against fresh data; it then sees
  `currentPlayers == maxPlayers` and fails with "This match is full."
- **It's tested.** `functions/test/functions/join_requests.test.mjs` fires
  concurrent accepts at the emulator:
  - 6 players for 1 remaining place: exactly 1 succeeds.
  - Two devices accepting the same player: counted once.
  - 8 accepts into an empty 5-player match: stops at exactly 5.

  Each run checks `currentPlayers`, the roster size and `status`.

## Adding a realtime screen

1. Add a `Stream` method to the feature's repository interface and implement it
   with `snapshots()`.
2. Expose it through a `StreamProvider.autoDispose` (add `.family` for per-ID data).
3. `ref.watch` it in the widget and handle `AsyncLoading` and `AsyncError`.
4. Add a matching method to the fake repository (see `test/fakes/`) that emits
   on change. Write a widget test that changes the data and asserts the UI
   updated without any user action (see `join_flow_test.dart`).

Anything that must stay consistent across users goes in a callable Cloud
Function with a transaction, not in client code.
