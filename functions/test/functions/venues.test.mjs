// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import { deleteAccount } from '../../lib/account/delete_account.js';
import { publishMatch } from '../../lib/matches/publish_match.js';
import { cancelBookingByVenue, releaseBooking } from '../../lib/venues/bookings.js';
import { applyVenueRating } from '../../lib/venues/ratings.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'venue-tests');
const db = getFirestore(app);
const HOUR = 60 * 60 * 1000;

const profile = (name) => ({
  fullName: name,
  username: name.toLowerCase().split(' ')[0],
  photoUrl: null,
  primaryPosition: 'striker',
  secondaryPositions: [],
  skillLevel: 'intermediate',
});

// The owner's uid is also the venue ID.
const OWNER = 'futsal_owner';
const slotStart = Date.now() + 48 * HOUR;

function draft(over = {}) {
  const start = Date.now() + 24 * HOUR;
  return {
    organizerId: 'raj',
    title: 'Booked Futsal',
    // What the organizer typed doesn't matter once a slot is booked.
    venue: { name: 'Typed name', address: '', city: 'Typed', placeId: null, lat: null, lng: null },
    startAt: Timestamp.fromMillis(start),
    endAt: Timestamp.fromMillis(start + HOUR),
    format: 'fiveASide',
    maxPlayers: 10,
    neededPositions: {},
    skillLevel: 'any',
    priceAmount: 150,
    isIndoor: false,
    description: '',
    rules: '',
    photos: [],
    booking: { venueId: OWNER, slotId: 's1' },
    ...over,
  };
}

const data = async (p) => (await db.doc(p).get()).data();
const exists = async (p) => (await db.doc(p).get()).exists;

async function rejects(promise, code, part) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code);
    if (part) assert.match(e.message, new RegExp(part, 'i'));
    return true;
  });
}

async function clearAll() {
  for (const c of ['matches', 'match_drafts', 'players', 'venues', 'owners', 'users']) {
    await db.recursiveDelete(db.collection(c));
  }
}

beforeEach(async () => {
  await clearAll();
  const b = db.batch();
  b.set(db.doc('players/raj'), profile('Raj Shrestha'));
  b.set(db.doc('players/sita'), profile('Sita Rai'));
  b.set(db.doc(`owners/${OWNER}`), { name: 'Hari Futsal', phone: '9800000000' });
  b.set(db.doc(`venues/${OWNER}`), {
    ownerId: OWNER,
    name: 'Dhuku Futsal',
    address: 'Baneshwor',
    city: 'Kathmandu',
    isIndoor: true,
    lat: null,
    lng: null,
  });
  b.set(db.doc(`venues/${OWNER}/slots/s1`), {
    startAt: Timestamp.fromMillis(slotStart),
    endAt: Timestamp.fromMillis(slotStart + HOUR),
    price: 2000,
    status: 'free',
  });
  await b.commit();
});
after(clearAll);

describe('booking a venue slot on publish', () => {
  test('match takes the venue and times from the slot; slot is booked', async () => {
    await db.doc('match_drafts/d1').set(draft());
    const r = await publishMatch(db, { draftId: 'd1', callerUid: 'raj' });
    assert.equal(r.bookedVenueId, OWNER);

    const m = await data('matches/d1');
    assert.deepEqual(m.venue, {
      name: 'Dhuku Futsal',
      address: 'Baneshwor',
      city: 'Kathmandu',
      placeId: null,
      lat: null,
      lng: null,
      venueId: OWNER,
    });
    assert.equal(m.startAt.toMillis(), slotStart);
    assert.equal(m.endAt.toMillis(), slotStart + HOUR);
    assert.equal(m.isIndoor, true);
    assert.deepEqual(m.booking, { venueId: OWNER, slotId: 's1', status: 'confirmed' });

    const slot = await data(`venues/${OWNER}/slots/s1`);
    assert.equal(slot.status, 'booked');
    assert.equal(slot.booking.matchId, 'd1');
    assert.equal(slot.booking.organizerName, 'Raj Shrestha');
    assert.equal(slot.booking.matchTitle, 'Booked Futsal');
  });

  test('two organizers race for one slot: exactly one gets it', async () => {
    await db.doc('match_drafts/d1').set(draft());
    await db.doc('match_drafts/d2').set(draft({ organizerId: 'sita', title: 'Other game' }));
    const results = await Promise.allSettled([
      publishMatch(db, { draftId: 'd1', callerUid: 'raj' }),
      publishMatch(db, { draftId: 'd2', callerUid: 'sita' }),
    ]);
    const ok = results.filter((r) => r.status === 'fulfilled');
    const failed = results.filter((r) => r.status === 'rejected');
    assert.equal(ok.length, 1);
    assert.equal(failed.length, 1);
    assert.match(failed[0].reason.message, /just booked/i);
    const slot = await data(`venues/${OWNER}/slots/s1`);
    assert.equal(slot.booking.matchId, ok[0].value.matchId);
    // The loser's draft is kept so they can pick another slot.
    const loserDraft = ok[0].value.matchId === 'd1' ? 'd2' : 'd1';
    assert.equal(await exists(`match_drafts/${loserDraft}`), true);
    assert.equal(await exists(`matches/${loserDraft}`), false);
  });

  test('a booked, missing or past slot is refused', async () => {
    await db.doc(`venues/${OWNER}/slots/s1`).update({ status: 'booked' });
    await db.doc('match_drafts/d1').set(draft());
    await rejects(publishMatch(db, { draftId: 'd1', callerUid: 'raj' }), 'failed-precondition', 'just booked');

    await db.doc('match_drafts/d1').set(draft({ booking: { venueId: OWNER, slotId: 'nope' } }));
    await rejects(publishMatch(db, { draftId: 'd1', callerUid: 'raj' }), 'failed-precondition', 'no longer available');

    await db.doc(`venues/${OWNER}/slots/old`).set({
      startAt: Timestamp.fromMillis(Date.now() - HOUR),
      endAt: Timestamp.fromMillis(Date.now()),
      price: 0,
      status: 'free',
    });
    await db.doc('match_drafts/d1').set(draft({ booking: { venueId: OWNER, slotId: 'old' } }));
    await rejects(publishMatch(db, { draftId: 'd1', callerUid: 'raj' }), 'failed-precondition', 'already started');
  });
});

describe('cancelling', () => {
  async function publishBooked() {
    await db.doc('match_drafts/d1').set(draft());
    await publishMatch(db, { draftId: 'd1', callerUid: 'raj' });
  }

  test('organizer cancels the match → slot is free again, owner told', async () => {
    await publishBooked();
    await db.doc('matches/d1').update({ status: 'cancelled' });
    const notes = await releaseBooking(db, 'd1', await data('matches/d1'));
    assert.equal(notes.length, 1);
    assert.equal(notes[0].uid, OWNER);
    assert.equal(notes[0].type, 'booking_cancelled');
    assert.equal(notes[0].route, '/owner');

    const slot = await data(`venues/${OWNER}/slots/s1`);
    assert.equal(slot.status, 'free');
    assert.equal(slot.booking, undefined);
    assert.equal((await data('matches/d1')).booking.status, 'released');

    // Running the trigger again does nothing.
    assert.deepEqual(await releaseBooking(db, 'd1', await data('matches/d1')), []);
  });

  test('venue cancels a booking → slot removed, organizer told', async () => {
    await publishBooked();
    const notes = await cancelBookingByVenue(db, { ownerUid: OWNER, slotId: 's1', reason: 'Pitch repairs' });
    assert.equal(notes.length, 1);
    assert.equal(notes[0].uid, 'raj');
    assert.equal(notes[0].type, 'venue_cancelled');
    assert.match(notes[0].body, /Pitch repairs/);

    assert.equal(await exists(`venues/${OWNER}/slots/s1`), false);
    const m = await data('matches/d1');
    assert.equal(m.booking.status, 'cancelled_by_venue');
    assert.equal(m.booking.reason, 'Pitch repairs');
    assert.equal(m.status, 'published');
  });

  test('only a booked slot can be cancelled, and only by its venue', async () => {
    await rejects(
      cancelBookingByVenue(db, { ownerUid: OWNER, slotId: 's1', reason: '' }),
      'failed-precondition',
      'not booked',
    );
    await publishBooked();
    // Another owner's uid points at a different (missing) venue.
    await rejects(
      cancelBookingByVenue(db, { ownerUid: 'someone_else', slotId: 's1', reason: '' }),
      'not-found',
    );
  });

  test('deleting an owner account cancels upcoming bookings and removes the venue', async () => {
    await publishBooked();
    const sent = [];
    const summary = await deleteAccount(
      {
        db,
        deleteAuthUser: async () => {},
        deleteFiles: async () => {},
        notify: async (items) => sent.push(...items),
      },
      OWNER,
    );
    assert.equal(summary.cancelledBookings, 1);
    assert.equal(sent.length, 1);
    assert.equal(sent[0].uid, 'raj');
    assert.equal(await exists(`venues/${OWNER}`), false);
    assert.equal(await exists(`owners/${OWNER}`), false);
    assert.equal((await data('matches/d1')).booking.status, 'cancelled_by_venue');
  });
});

describe('venue ratings', () => {
  const rating = (over = {}) => ({
    matchId: 'm1',
    reviewerId: 'raj',
    overall: 4,
    pitch: 5,
    facilities: 3,
    value: 4,
    comment: 'Great turf',
    reviewer: { name: 'Raj Shrestha', photoUrl: null },
    ...over,
  });

  test('averages per part, counted once, owner notified', async () => {
    await db.doc(`venues/${OWNER}/ratings/m1_raj`).set(rating());
    const note = await applyVenueRating(db, OWNER, 'm1_raj');
    assert.equal(note.uid, OWNER);
    assert.equal(note.type, 'new_venue_rating');
    assert.equal(note.route, '/owner/venue');
    assert.equal(await applyVenueRating(db, OWNER, 'm1_raj'), null);

    await db.doc(`venues/${OWNER}/ratings/m1_sita`).set(
      rating({ reviewerId: 'sita', overall: 5, pitch: 4, facilities: 2, value: 5, comment: '' }),
    );
    await applyVenueRating(db, OWNER, 'm1_sita');

    const r = (await data(`venues/${OWNER}`)).rating;
    assert.equal(r.count, 2);
    assert.equal(r.overall, 4.5);
    assert.equal(r.pitch, 4.5);
    assert.equal(r.facilities, 2.5);
    assert.equal(r.value, 4.5);
  });
});
