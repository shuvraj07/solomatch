# Live match center

Anyone signed in can watch a match live from its page. The organizer posts
goals and cards as they happen, and followers get a push for every goal.

## What people see

| Phase | Match page | Home |
|---|---|---|
| Before kick-off | Compact row below the roster: "Team A vs Team B", follower count, **Follow** (organizer: edit team names) | Upcoming list |
| Live (kicked off, before `endAt`) | Scoreboard at the top: team names, big score, **● LIVE 37'**, timeline, Follow. The organizer also gets the controls. | "Live now" card: `Tigers 2 – 1 Eagles · 37'` |
| Full time | Scoreboard with **FULL TIME** and the timeline (hidden if nothing was posted) | – |

The minute is football-style (1' in the first minute), counted from
`startAt` and capped at the match length. It refreshes every 30 seconds.

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
| Full time (`full_time`) | Same audience, when the match completes with a score | "🏁 Full time: Tigers 2 – 1 Eagles" |

Both belong to the **Match updates** notification setting.
