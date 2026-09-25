# Notifications

Every notification is created on the server. The app never notifies other
users directly.

```
Firestore change ──trigger──▶ messages.ts (who gets what) ──▶ deliver.ts
                                                               ├─ users/{uid}/notifications/{id}  (inbox, live in the app)
                                                               └─ FCM push to users/{uid}/devices/*
```

## Events

| Type | Trigger | Recipient |
|---|---|---|
| `new_request` | request created, or re-requested after withdrawing | organizer |
| `request_accepted` / `request_rejected` | request `pending` → `accepted`/`rejected` | player |
| `player_left` | request `accepted` → `cancelled` | organizer |
| `match_almost_full` | `spotsRemaining` drops to 2 | organizer |
| `match_full` | status → `full` | organizer |
| `match_cancelled` | status → `cancelled` | roster + pending requesters |
| `match_reminder` | scheduled job: 24 h, 2 h, 30 min before kick-off | organizer + roster |
| `kick_off` | status → `started` | organizer + roster |
| `request_expired` | request still `pending` at kick-off → `expired` | player |
| `report_reminder` | status → `completed` | organizer |
| `added_to_match` | organizer pre-confirmed them when publishing | player |
| `motm_vote` | status → `completed` | roster |
| `motm_won` | `motm` decided | winner(s) |
| `new_review` | someone rated you | the rated player |

The rules are pure functions in `functions/src/notifications/messages.ts` and are
unit-tested in `functions/test/functions/notifications.test.mjs`.

## Reliability

- **Idempotent.** Triggers can fire more than once, so the inbox doc ID is
  derived from the event ID. A retry finds it already there and sends nothing.
- **Reminders.** Each one is claimed in a transaction (`remindersSent.h24/h2/m30`).
  Only the tightest due window is sent, so a match posted 90 minutes ahead gets
  the 2-hour reminder, not a late "tomorrow".
- **Dead tokens.** Tokens FCM reports as unregistered are deleted.

## The app side

- `PushCoordinator` (wraps the app):
  - after sign-in, requests permission (Android 13+ prompt) and stores the FCM
    token in `users/{uid}/devices/{token}`, refreshing it when FCM rotates it
  - foreground pushes show a snackbar with **View**
  - tapping a notification (background or cold start) opens `data.route`, once
    the session is ready
- **Sign out** goes through `signOutProvider`, which removes this phone's token
  *before* signing out.
- The **🔔 bell** on Home shows the live unread count and opens the inbox.
  Opening an item marks it read and goes to the match.

## Testing a real push

1. Install the app and sign in on a phone, then allow notifications.
2. From a second account, request to join a match the first account organizes.
3. The first phone gets "New join request", even with the app closed.
