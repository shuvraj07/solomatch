import { FieldValue, type Firestore } from 'firebase-admin/firestore';

import type { Outgoing } from '../notifications/messages.js';
import { OWNER_ROUTE } from './bookings.js';

export const RATING_PARTS = ['overall', 'pitch', 'facilities', 'value'] as const;

const round = (n: number) => Math.round(n * 100) / 100;

/**
 * Adds a player's venue rating (`venues/{venueId}/ratings/{id}`) to
 * `venues/{venueId}.rating`: `count`, a `<part>Sum` and an average per part.
 * Security rules already checked the player was at a match there.
 * Idempotent via the `counted` flag.
 */
export async function applyVenueRating(
  db: Firestore,
  venueId: string,
  ratingId: string,
): Promise<Outgoing | null> {
  const venueRef = db.collection('venues').doc(venueId);
  const ratingRef = venueRef.collection('ratings').doc(ratingId);

  return db.runTransaction(async (tx) => {
    const [venueSnap, ratingSnap] = await tx.getAll(venueRef, ratingRef);
    const venue = venueSnap.data();
    const rating = ratingSnap.data();
    if (!venue || !rating || rating.counted === true) return null;

    const old = venue.rating ?? {};
    const count = (old.count ?? 0) + 1;
    const next: Record<string, number> = { count };
    for (const part of RATING_PARTS) {
      const sum = (old[`${part}Sum`] ?? 0) + rating[part];
      next[`${part}Sum`] = sum;
      next[part] = round(sum / count);
    }
    tx.update(venueRef, { rating: next });
    tx.update(ratingRef, { counted: true, countedAt: FieldValue.serverTimestamp() });

    return {
      uid: venueId,
      type: 'new_venue_rating',
      title: `New rating ${'⭐'.repeat(rating.overall)}`,
      body: rating.comment
        ? `${rating.reviewer?.name ?? 'A player'}: "${String(rating.comment).slice(0, 120)}"`
        : `${rating.reviewer?.name ?? 'A player'} rated ${venue.name}.`,
      matchId: rating.matchId,
      route: `${OWNER_ROUTE}/venue`,
    } satisfies Outgoing;
  });
}
