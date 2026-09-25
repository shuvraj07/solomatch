import {
  FieldValue,
  type DocumentData,
  type DocumentReference,
  type Firestore,
  type Timestamp,
  type Transaction,
} from 'firebase-admin/firestore';

import { kickOffLabel, type Outgoing } from '../notifications/messages.js';
import { RuleError } from '../shared/rule_error.js';

/**
 * Venue bookings. A venue owner lists free time slots
 * (`venues/{ownerUid}/slots/{slotId}`); an organizer books one by
 * publishing a match with `booking` in the draft (see publishMatch, which
 * locks the slot in the same transaction, so a slot can't be double-booked).
 *
 * Slot `status`: `free` → `booked` (publish) → `free` again if the
 * organizer cancels the match. If the venue cancels, the slot is deleted
 * and the match keeps `booking.status = 'cancelled_by_venue'`.
 */

/** Where the owner is sent from a booking notification. */
export const OWNER_ROUTE = '/owner';

const STARTED = ['started', 'completed'];

/** The slot to book, read and checked inside the publish transaction. */
export interface BookedSlot {
  slotRef: DocumentReference;
  venueId: string;
  slotId: string;
  venue: {
    name: string;
    address: string;
    city: string;
    placeId: null;
    lat: number | null;
    lng: number | null;
    venueId: string;
  };
  startAt: Timestamp;
  endAt: Timestamp;
  isIndoor: boolean;
}

/**
 * Reads the requested slot in [tx] and checks it can be booked. Must run
 * before any writes in the transaction.
 */
export async function readSlotForBooking(
  db: Firestore,
  tx: Transaction,
  booking: unknown,
  organizerUid: string,
  now: Date,
): Promise<BookedSlot> {
  const b = (booking ?? {}) as Record<string, unknown>;
  const venueId = b.venueId;
  const slotId = b.slotId;
  if (typeof venueId !== 'string' || typeof slotId !== 'string' || !venueId || !slotId) {
    throw new RuleError('invalid-argument', 'Pick a time slot again.');
  }
  if (venueId === organizerUid) {
    throw new RuleError('invalid-argument', "You can't book your own venue as a player.");
  }
  const venueRef = db.collection('venues').doc(venueId);
  const slotRef = venueRef.collection('slots').doc(slotId);
  const [venueSnap, slotSnap] = await tx.getAll(venueRef, slotRef);
  const venue = venueSnap.data();
  const slot = slotSnap.data();
  if (!venue || !slot) {
    throw new RuleError('failed-precondition', 'That slot is no longer available. Pick another time.');
  }
  if (slot.status !== 'free') {
    throw new RuleError(
      'failed-precondition',
      'Someone just booked that slot. Pick another time.',
    );
  }
  if ((slot.startAt as Timestamp).toMillis() <= now.getTime()) {
    throw new RuleError('failed-precondition', 'That slot has already started. Pick a later one.');
  }
  return {
    slotRef,
    venueId,
    slotId,
    venue: {
      name: venue.name,
      address: venue.address ?? '',
      city: venue.city,
      placeId: null,
      lat: typeof venue.lat === 'number' ? venue.lat : null,
      lng: typeof venue.lng === 'number' ? venue.lng : null,
      venueId,
    },
    startAt: slot.startAt,
    endAt: slot.endAt,
    isIndoor: venue.isIndoor === true,
  };
}

/** Tells the owner their slot was booked. */
export function bookedNotice(
  venueId: string,
  matchId: string,
  title: string,
  organizerName: string,
  startMs: number,
): Outgoing {
  return {
    uid: venueId,
    type: 'venue_booked',
    title: 'New booking 📅',
    body: `${organizerName} booked ${kickOffLabel(startMs)} for "${title}".`,
    matchId,
    route: OWNER_ROUTE,
  };
}

/**
 * The organizer cancelled a match that had a booking → free the slot and
 * tell the owner. Idempotent: only frees a slot still held by this match.
 */
export async function releaseBooking(
  db: Firestore,
  matchId: string,
  match: DocumentData,
): Promise<Outgoing[]> {
  const b = match.booking;
  if (!b || b.status !== 'confirmed') return [];
  const matchRef = db.collection('matches').doc(matchId);
  const slotRef = db.collection('venues').doc(b.venueId).collection('slots').doc(b.slotId);

  const freed = await db.runTransaction(async (tx) => {
    const slot = (await tx.get(slotRef)).data();
    tx.update(matchRef, { 'booking.status': 'released' });
    if (!slot || slot.booking?.matchId !== matchId) return false;
    tx.update(slotRef, { status: 'free', booking: FieldValue.delete() });
    return true;
  });
  if (!freed) return [];
  return [
    {
      uid: b.venueId,
      type: 'booking_cancelled',
      title: 'Booking cancelled',
      body: `"${match.title}" on ${kickOffLabel(match.startAt.toMillis())} was cancelled. The slot is free again.`,
      matchId,
      route: OWNER_ROUTE,
    },
  ];
}

/**
 * The venue owner cancels a booking (e.g. the pitch is closed). The slot is
 * removed and the organizer is told to make other arrangements.
 */
export async function cancelBookingByVenue(
  db: Firestore,
  input: { ownerUid: string; slotId: string; reason: string },
): Promise<Outgoing[]> {
  const reason = input.reason.trim().slice(0, 200);
  const venueRef = db.collection('venues').doc(input.ownerUid);
  const slotRef = venueRef.collection('slots').doc(input.slotId);

  return db.runTransaction(async (tx) => {
    const [venueSnap, slotSnap] = await tx.getAll(venueRef, slotRef);
    const venue = venueSnap.data();
    const slot = slotSnap.data();
    if (!venue || !slot) throw new RuleError('not-found', 'Slot not found.');
    if (slot.status !== 'booked' || !slot.booking?.matchId) {
      throw new RuleError('failed-precondition', 'This slot is not booked.');
    }
    const matchRef = db.collection('matches').doc(slot.booking.matchId);
    const match = (await tx.get(matchRef)).data();
    if (match && STARTED.includes(match.status)) {
      throw new RuleError('failed-precondition', 'This match has already started.');
    }

    tx.delete(slotRef);
    if (!match) return [];
    tx.update(matchRef, {
      booking: {
        ...(match.booking ?? { venueId: input.ownerUid, slotId: input.slotId }),
        status: 'cancelled_by_venue',
        reason,
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (match.status === 'cancelled') return [];
    return [
      {
        uid: match.organizer.uid,
        type: 'venue_cancelled',
        title: `${venue.name} cancelled your booking`,
        body:
          (reason ? `"${reason}" · ` : '') +
          `${match.title}, ${kickOffLabel(match.startAt.toMillis())}. Contact the venue or cancel the match.`,
        matchId: matchRef.id,
      },
    ];
  });
}
