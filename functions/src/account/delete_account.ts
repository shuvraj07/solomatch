import { FieldValue, type Firestore } from 'firebase-admin/firestore';

import type { Outgoing } from '../notifications/messages.js';
import { leaveMatch } from '../requests/join_requests.js';
import { cancelBookingByVenue } from '../venues/bookings.js';

const UPCOMING = ['published', 'filling', 'full'];

export interface DeleteDeps {
  db: Firestore;
  /** Deletes the Firebase Auth user (admin SDK in production). */
  deleteAuthUser: (uid: string) => Promise<void>;
  /** Deletes Storage files under a prefix (profile photo, uploads). */
  deleteFiles: (prefix: string) => Promise<void>;
  /** Sends notifications (organizers whose venue bookings are cancelled). */
  notify?: (items: Outgoing[]) => Promise<unknown>;
}

export interface DeleteSummary {
  leftMatches: number;
  cancelledMatches: number;
  /** Venue owners: upcoming bookings cancelled. */
  cancelledBookings: number;
}

/**
 * Deletes a user's account and personal data (Google Play / GDPR style
 * "delete account"). Order matters so every step leaves consistent data
 * and the whole thing can safely be retried:
 *
 *  1. Leave upcoming matches they play in (frees the places, notifies the
 *     organizer via the usual triggers).
 *  2. Cancel upcoming matches they organize (players are notified).
 *  3. Withdraw pending requests.
 *  4. Delete profile, username claim, private data (devices, inbox,
 *     blocks) and uploaded files.
 *  5. Delete the login.
 *
 * Venue owners: upcoming bookings are cancelled (organizers are told), then
 * the owner profile and venue, with its slots and ratings, are deleted.
 *
 * Kept on purpose: past matches, chat messages and reviews they wrote, as
 * other people's history depends on them. Their name there is replaced
 * with "Deleted player" where it's stored with the account.
 */
export async function deleteAccount(deps: DeleteDeps, uid: string): Promise<DeleteSummary> {
  const { db } = deps;
  const now = new Date();
  let leftMatches = 0;
  let cancelledMatches = 0;
  let cancelledBookings = 0;

  // Venue owner: cancel upcoming bookings, then remove the venue.
  const venueRef = db.collection('venues').doc(uid);
  const booked = await venueRef.collection('slots').where('status', '==', 'booked').get();
  const notices: Outgoing[] = [];
  for (const slot of booked.docs) {
    if (slot.data().startAt.toDate() <= now) continue;
    try {
      notices.push(
        ...(await cancelBookingByVenue(db, {
          ownerUid: uid,
          slotId: slot.id,
          reason: 'The venue closed its SoloMatch account.',
        })),
      );
      cancelledBookings++;
    } catch (e) {
      console.warn('cancel booking failed', slot.id, e);
    }
  }
  if (notices.length && deps.notify) await deps.notify(notices);
  await db.recursiveDelete(venueRef);
  await db.collection('owners').doc(uid).delete();
  await deps.deleteFiles(`venue_photos/${uid}/`);

  // 1 + 3. Matches they asked to join.
  const requests = await db.collectionGroup('requests').where('player.uid', '==', uid).get();
  for (const r of requests.docs) {
    const matchRef = r.ref.parent.parent;
    if (!matchRef) continue;
    const match = (await matchRef.get()).data();
    const upcoming = match && UPCOMING.includes(match.status) && match.startAt.toDate() > now;
    const status = r.data().status;
    if (upcoming && status === 'accepted') {
      await leaveMatch(db, { matchId: matchRef.id, callerUid: uid });
      leftMatches++;
    } else if (upcoming && status === 'pending') {
      await r.ref.update({ status: 'cancelled', updatedAt: FieldValue.serverTimestamp() });
    }
  }

  // 2. Matches they organize.
  const organized = await db
    .collection('matches')
    .where('organizer.uid', '==', uid)
    .where('status', 'in', UPCOMING)
    .get();
  for (const m of organized.docs) {
    await m.ref.update({ status: 'cancelled', updatedAt: FieldValue.serverTimestamp() });
    cancelledMatches++;
  }

  // Anonymize their name where it's shown to others.
  const anon = { name: 'Deleted player', photoUrl: null };
  const conversations = await db
    .collection('conversations')
    .where('participantIds', 'array-contains', uid)
    .get();
  for (const c of conversations.docs) {
    await c.ref.update({
      participantIds: FieldValue.arrayRemove(uid),
      [`participants.${uid}`]: anon,
    });
  }
  const written = await db.collection('reviews').where('reviewerId', '==', uid).get();
  for (const r of written.docs) await r.ref.update({ reviewer: anon });

  // 4. Profile and private data.
  const player = (await db.collection('players').doc(uid).get()).data();
  if (player?.username) await db.collection('usernames').doc(player.username).delete();
  await db.collection('players').doc(uid).delete();
  await db.recursiveDelete(db.collection('users').doc(uid));
  const drafts = await db.collection('match_drafts').where('organizerId', '==', uid).get();
  await Promise.all(drafts.docs.map((d) => d.ref.delete()));
  await deps.deleteFiles(`users/${uid}/`);
  await deps.deleteFiles(`match_photos/${uid}/`);
  await deps.deleteFiles(`chat_images/${uid}/`);

  // 5. The login itself, last, so a failure above can be retried.
  await deps.deleteAuthUser(uid);
  return { leftMatches, cancelledMatches, cancelledBookings };
}
