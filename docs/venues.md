# Venues, owners and bookings

Futsal and pitch owners can list their venue and the times it's free.
Organizers can book one of those times when they create a match. Typing a
venue by hand still works exactly as before; booking is optional.

## Two kinds of account

The sign-in and sign-up screens have a **Player | Venue owner** switch
(`accountModeProvider`). It only decides which setup screen a **new**
account sees:

| Setup | Creates | Then |
|---|---|---|
| Player (5 steps) | `players/{uid}` + `usernames/{name}` | Player app (Home, Discover, Messages, Profile) |
| Venue owner (one form) | `owners/{uid}` + `venues/{uid}` | Owner app (Schedule, Venue, Account) |

An account is one or the other. The rules refuse to create `owners/{uid}` if
`players/{uid}` exists, and the other way round. `sessionProvider` watches
both documents and produces `Ready` (player), `OwnerReady` (owner) or
`NeedsProfile`. `sessionRedirect` keeps each kind in its own app. Owners can
also open Settings and the notification inbox. Signing in with the "wrong"
switch still opens the account's own app.

Each owner has **one venue**, and its document ID is the owner's uid. That
keeps the rules simple (`isUser(venueId)`). Supporting several venues per
owner later means moving to generated IDs plus an `ownerId` check.

## Slots

`venues/{venueId}/slots/{slotId}`: `{startAt, endAt, price, status}` and a
server-written `booking`.

- The owner adds slots from **Schedule → Add slots**: opening hours are split
  into 60, 90 or 120-minute slots, optionally repeated for 7, 14 or 28 days
  on chosen weekdays (`SlotPlanner`, which is unit-tested). It skips times
  that have already started and times that overlap existing slots.
- Each free slot has a **Booked / Free switch**. The owner uses it for
  bookings made outside the app (phone, walk-in). The slot becomes
  `status: 'booked'` with `booking: {offline: true, note, markedAt}`, and
  organizers can no longer book it. Tapping the slot lets the owner add a
  short note (e.g. "Ram's team"). Slots are readable by any signed-in user,
  so the note shouldn't hold phone numbers.
- The owner can flip an offline booking back to free, or remove free and
  offline-booked slots.
- **App bookings** (made by an organizer's match) have no switch. Only the
  server books them, and the owner cancels them with **Cancel booking**, so
  the organizer is always told.

## Booking flow

```
Organizer: Discover → Venues → venue → day → free slot → "Set up match"
      or: Create match → Venue step → "Book a free slot at a SoloMatch venue"
   → draft.booking = {venueId, slotId}; venue, date and times come from the slot
     (the flow skips the Location / Date / Kick-off / Final whistle steps)
   → Publish → publishDraft (one transaction):
        read slot → must be `free` and in the future
        match.venue = the venue doc (+ venueId), times = the slot's
        match.booking = {venueId, slotId, status: 'confirmed'}
        slot.status = 'booked', slot.booking = {matchId, matchTitle, organizer…}
   → owner notified: venue_booked
```

Because the check and the write happen in one transaction, two organizers
can't book the same slot. The loser gets "Someone just booked that slot",
and their draft is kept (tested in `functions/test/functions/venues.test.mjs`).

The suggested per-player price is the slot price divided by the number of
players. The organizer can change it.

### Cancelling

| Who | How | Effect |
|---|---|---|
| Organizer | Cancels the match | `onMatchUpdated` → `releaseBooking`: slot back to `free`, `match.booking.status = 'released'`, owner notified (`booking_cancelled`) |
| Venue owner | Schedule → booked slot → Cancel booking (optional reason) | `cancelVenueBooking` callable: slot deleted, `match.booking.status = 'cancelled_by_venue'` + `reason`, organizer notified (`venue_cancelled`). The match page shows a warning banner. |
| Owner deletes account | Settings → Delete account | Every upcoming booking is cancelled as above, then the venue, slots and ratings are removed |

The match stays published when the venue cancels. The organizer can contact
the venue or cancel the match; changing a published match's venue isn't
supported yet.

## Venue ratings

After a **completed** match at a SoloMatch venue (`match.venue.venueId`
set), the organizer and roster players see **Rate <venue>** on the match
page for 14 days. They score 1–5 for overall, pitch quality, facilities and
value for money, and can add an optional comment.

- `venues/{venueId}/ratings/{matchId}_{uid}`: one rating per player per
  match, create-only. The rules check that the player was there, the match
  was at this venue, and the reviewer's name matches their profile.
- `onVenueRatingCreated` → `applyVenueRating` updates `venue.rating`
  (`count`, per-part sums and averages; idempotent via `counted`) and
  notifies the owner (`new_venue_rating`).
- The venue page (players) and the owner's **Venue** tab show the averages
  as bars, plus recent comments.

Yellow and red cards are unchanged: the organizer records them in the match
report.

## Notifications for owners

Inbox entries can carry a `route`. Owner notifications use `/owner` or
`/owner/venue` and open the owner app instead of the match page. In
Settings, owners see only two toggles: **Bookings** (the `matches`
category) and **Venue ratings** (`reviews`).
