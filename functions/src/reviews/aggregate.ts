import { FieldValue, type Firestore } from 'firebase-admin/firestore';

import type { Outgoing } from '../notifications/messages.js';

/**
 * Adds a new review to the reviewee's rating. Security rules have already
 * checked who may review whom; this only does the maths.
 *
 * Idempotent: the review is marked `counted` in the same transaction, so a
 * retried trigger never counts it twice.
 */
export async function applyReview(
  db: Firestore,
  reviewId: string,
): Promise<Outgoing | null> {
  const reviewRef = db.collection('reviews').doc(reviewId);

  return db.runTransaction(async (tx) => {
    const review = (await tx.get(reviewRef)).data();
    if (!review || review.counted === true) return null;
    const playerRef = db.collection('players').doc(review.revieweeId);
    const player = (await tx.get(playerRef)).data();
    if (!player) return null;

    const stats = player.stats ?? {};
    const count = (stats.ratingCount ?? 0) + 1;
    const sum = (stats.ratingSum ?? (stats.ratingAvg ?? 0) * (stats.ratingCount ?? 0)) + review.rating;

    tx.set(
      playerRef,
      {
        stats: {
          ratingCount: count,
          ratingSum: sum,
          ratingAvg: Math.round((sum / count) * 100) / 100,
        },
      },
      { merge: true },
    );
    tx.update(reviewRef, { counted: true, countedAt: FieldValue.serverTimestamp() });

    return {
      uid: review.revieweeId,
      matchId: review.matchId,
      type: 'new_review',
      title: `${review.reviewer?.name ?? 'A player'} rated you ${'⭐'.repeat(review.rating)}`,
      body: review.comment
        ? `"${String(review.comment).slice(0, 120)}" · ${review.matchTitle}`
        : `For ${review.matchTitle}.`,
    } satisfies Outgoing;
  });
}
