# Discover, search and recommendations

## Live now (Home)

`MatchRepository.watchLiveMatches` lists matches being played right now.
It queries matches whose status is open, filling, full or started and whose
`endAt` is in the future, ordered by `endAt`. It then keeps those that have
kicked off (`startAt <= now`). This covers the few minutes between kick-off
and `advanceMatchLifecycle` marking the match `started`. It uses the existing
`(status, endAt)` index. Live cards show a red **● LIVE** chip. When a match
completes, the server sets its status to `completed` and it leaves the list.

## Discover

`discoverPoolProvider` streams the next 100 upcoming matches.
`MatchFilters.accepts` then filters them on the device. Firestore has no
full-text search, and 100 matches is plenty for one city. When that stops
being true, move search to a search service (for example Algolia or
Typesense) or add server-side filters by city.

| Filter | Where | Rule |
|---|---|---|
| Search | Text field | Every word must appear in the title, venue name, address or city (case-insensitive) |
| Date | Chips | Any day, Today, Tomorrow, Next 7 days, Weekend (the coming Sat/Sun) |
| Format | Sheet | 5v5 / 7v7 / 9v9 / 11v11, multi-select |
| Level | Sheet | Matches for that level plus "any level" matches |
| Needs a player for | Sheet | An open place in that group or an "any position" place |
| Venue | Sheet | Indoor / outdoor |
| Free only | Sheet | `price.amount == 0` |
| Show full matches | Sheet | Off by default |

Filters live in `discoverFiltersProvider`, which is not auto-disposed, so
they survive tab switches. The badge on **Filters** counts active sheet filters.

## Recommendations: `MatchingService`

`lib/features/discover/domain/matching_service.dart` is pure Dart (no Flutter
or Firebase) and fully unit-tested. It scores each match for the signed-in
player (max 100):

| Signal | Points | Reason shown |
|---|---|---|
| Open place for the main position | 30 | "Needs a MID" |
| …or for a secondary position | 15 | "Needs a DEF" |
| …or only "any position" places | 10 | none |
| Match level = player level | 25 | "Your level" |
| Match is "any level" | 15 | "All levels" |
| One level apart | 10 | none |
| Availability covers kick-off (weekday + time band) | 20 | "Fits your schedule" |
| Same city | 15 | "In Kathmandu" |
| Kick-off within 3 days | 10 | none |

Matches the player can't join (their own, full, or not accepting requests)
score −1 and go last. With **Recommended** sort (the default), results are
ordered by score, and ties go to the sooner match. **Soonest** orders by
kick-off. Matches scoring ≥ 50 show their reasons on the card
("✨ Needs a MID · Your level · In Kathmandu").

When Maps lands, add a distance signal here and a distance filter.
`MatchCard.distanceLabel` is already there.

## Time in tests

`clockProvider` (`lib/app/providers/clock_provider.dart`) supplies "now".
`pumpApp(now: testNow)` pins it so date filters and scores are stable.
