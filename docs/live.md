# Live match center

Anyone signed in can watch a match live from its page. The organizer posts
goals and cards as they happen, and followers get a push for every goal.

## What people see

| Phase | Match page | Home |
|---|---|---|
| Before kick-off | Compact row below the roster: "Team A vs Team B", follower count, **Follow** (organizer: edit team names) | Upcoming list |
| Live (kicked off, before `endAt`) | Scoreboard at the top: team names, big score, **● LIVE 37'**, timeline, Follow. The organizer also gets the controls. | "Live now" card: `Tigers 2 – 1 Eagles · 37'` |
| Full time | Scoreboard with **FULL TIME** and the timeline (hidden if nothing was posted) | – |

### The match clock

Until the organizer taps **▶ Kick off**, the minute follows the schedule
(1' in the first minute, counted from `startAt`, capped at the match length).
From then on, the organizer's whistle drives a real clock shown as **37:12**,
ticking every second:

```
▶ Kick off → ⏸ Half-time → ▶ 2nd half → 🏁 Full time
```

`matches/{id}.clock = {phase, periodStartedAt, elapsedBefore}`:

- `phase`: `first_half` | `half_time` | `second_half` | `full_time`.
- `periodStartedAt`: the server time the running period started, or null
  while paused.
- `elapsedBefore`: seconds played before the running period.

Time played is `elapsedBefore + (now − periodStartedAt)` while running,
otherwise `elapsedBefore`. This allows late kick-offs, a half-time pause and
stoppage time, capped at 200 minutes. The rules allow clock changes only by
the organizer, 10 minutes before kick-off to 3 hours after the end.
**Full time** asks for confirmation. It stops the clock and sends the
full-time push straight away. It doesn't complete the match early: the
scheduled lifecycle still does that at `endAt`.

## Organizer controls

- **⚽ Team A / ⚽ Team B:** pick the scorer from the roster (or "Guest / not
  sure"). The minute is prefilled and can be adjusted.
- **🟨 Yellow / 🟥 Red:** pick the team and the player.
- **Undo:** removes the last event, after a confirmation.
- **✏️ Team names:** 1–30 characters each; the defaults are "Team A" and
  "Team B".

The organizer can post from 10 minutes before kick-off until 3 hours after
the final whistle (`LiveMatch.canPost`, matched in `firestore.rules`).

When the organizer opens the match report for the first time, it's
prefilled from the live goals and cards (`LiveMatch.reportLines`). They can
then add assists and fix anything.

## Data

| Path | Written by | Notes |
|---|---|---|
| `matches/{id}.teams` | Organizer | `{home, away}` |
| `matches/{id}/events/{eventId}` | Organizer (create/delete only) | `{type: goal \| yellow \| red, team: home \| away, playerUid?, playerName, minute, by, createdAt}`; readable by anyone signed in |
| `matches/{id}.score` 🔒 | `onMatchEventWritten` | `{home, away}`, recounted from all events on every add or undo, so it can't drift |
| `matches/{id}/followers/{uid}` | That user | `{createdAt}`; only readable by the follower |
| `matches/{id}.followerCount` 🔒 | `onMatchFollowerWritten` | Incremented or decremented; approximate if a trigger is retried |

The match page counts the score from the event stream itself, so it updates
instantly. Lists use the server's `score`.

## Notifications (push only, no inbox entry)

| Event | Who | Example |
|---|---|---|
| Goal (`live_goal`) | Organizer, roster and followers, except the person who posted it | "⚽ GOAL! Tigers 1 – 0 Eagles" · "Amit Karki (Tigers) scores 12' · Friday Futsal" |
| Full time (`full_time`) | Same audience, once: at the organizer's 🏁 Full time, or when the match completes if it was followed live | "🏁 Full time: Tigers 2 – 1 Eagles" |

Both belong to the **Match updates** notification setting.

## Player fitness

Players set their own fitness on their Profile tab:
**✅ Fully fit** (default), **🤕 Minor knock** or **🚑 Injured**
(`players/{uid}.fitness`: `fit` | `doubtful` | `injured`). Other players see a
badge on the profile unless the player is fully fit.

An injured player can't be selected:

| Where | App | Server |
|---|---|---|
| Request to join | Blocked with a message | Rules refuse the request |
| Organizer accepting a request | Card shows "🚑 Injured", Accept disabled | `acceptJoinRequest` refuses |
| "Your players" when creating a match | Shown but greyed out | `publishDraft` refuses (also "I'm playing too" if the organizer is injured) |

A **minor knock** is allowed: the request card warns the organizer, "check
before accepting". A player who gets injured after being accepted stays on
the roster; the organizer can see the badge on their profile.
