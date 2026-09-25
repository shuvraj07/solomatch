import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';
import { createTestEnv, db, profileDoc } from './helpers.mjs';

const HOUR = 3600 * 1000;
const at = (ms) => Timestamp.fromMillis(Date.now() + ms);

const ownerDoc = (over = {}) => ({
  name: 'Hari Thapa',
  phone: '+977 9800000000',
  createdAt: serverTimestamp(),
  ...over,
});

const venueDoc = (uid, over = {}) => ({
  ownerId: uid,
  name: 'Dhuku Futsal',
  searchName: 'dhuku futsal',
  address: 'Baneshwor',
  city: 'Kathmandu',
  phone: '9800000000',
  description: '',
  isIndoor: true,
  formats: ['fiveASide'],
  pricePerHour: 2000,
  amenities: ['parking', 'floodlights'],
  photos: [],
  lat: null,
  lng: null,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...over,
});

const slotDoc = (over = {}) => ({
  startAt: at(24 * HOUR),
  endAt: at(25 * HOUR),
  price: 2000,
  status: 'free',
  createdAt: serverTimestamp(),
  ...over,
});

describe('venue owners, venues, slots and venue ratings', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  const seedOwner = (uid = 'hari') =>
    env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, `owners/${uid}`), { name: 'Hari', phone: '9800000000' });
      await setDoc(doc(fs, `venues/${uid}`), { ...venueDoc(uid), createdAt: at(0), updatedAt: at(0) });
    });

  test('owner profile: own doc, valid phone, not if already a player', async () => {
    await assertSucceeds(setDoc(doc(db(env, 'hari'), 'owners/hari'), ownerDoc()));
    await assertFails(setDoc(doc(db(env, 'sita'), 'owners/hari'), ownerDoc()));
    await assertFails(setDoc(doc(db(env, 'sita'), 'owners/sita'), ownerDoc({ phone: 'call me' })));

    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'players/amit'), { fullName: 'Amit' }),
    );
    await assertFails(setDoc(doc(db(env, 'amit'), 'owners/amit'), ownerDoc()));
  });

  test('an owner cannot also create a player profile', async () => {
    await seedOwner('hari');
    const fs = db(env, 'hari');
    const b = writeBatch(fs);
    b.set(doc(fs, 'players/hari'), profileDoc({ username: 'hari' }));
    b.set(doc(fs, 'usernames/hari'), { uid: 'hari' });
    await assertFails(b.commit());
  });

  test('venue: created by its owner (ID = uid), rating is server-only', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'owners/hari'), { name: 'Hari', phone: '9800000000' }),
    );
    const fs = db(env, 'hari');
    await assertFails(setDoc(doc(fs, 'venues/other'), venueDoc('other')));
    await assertFails(setDoc(doc(fs, 'venues/hari'), venueDoc('hari', { formats: [] })));
    await assertFails(setDoc(doc(fs, 'venues/hari'), venueDoc('hari', { amenities: ['pool'] })));
    await assertFails(
      setDoc(doc(fs, 'venues/hari'), venueDoc('hari', { rating: { count: 99, overall: 5 } })),
    );
    await assertSucceeds(setDoc(doc(fs, 'venues/hari'), venueDoc('hari')));

    await assertSucceeds(
      updateDoc(doc(fs, 'venues/hari'), { pricePerHour: 2500, updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(doc(fs, 'venues/hari'), { rating: { count: 1 }, updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(doc(db(env, 'sita'), 'venues/hari'), { pricePerHour: 1, updatedAt: serverTimestamp() }),
    );
    // A player (not an owner) can't create a venue for themselves.
    await assertFails(setDoc(doc(db(env, 'sita'), 'venues/sita'), venueDoc('sita')));
  });

  test('slots: owner adds free future slots; booking is server-only', async () => {
    await seedOwner('hari');
    const fs = db(env, 'hari');
    await assertSucceeds(setDoc(doc(fs, 'venues/hari/slots/s1'), slotDoc()));
    await assertFails(setDoc(doc(fs, 'venues/hari/slots/s2'), slotDoc({ status: 'booked' })));
    await assertFails(setDoc(doc(fs, 'venues/hari/slots/s3'), slotDoc({ startAt: at(-HOUR), endAt: at(HOUR) })));
    await assertFails(setDoc(doc(fs, 'venues/hari/slots/s4'), slotDoc({ endAt: at(24 * HOUR + 10 * 60000) })));
    await assertFails(setDoc(doc(db(env, 'sita'), 'venues/hari/slots/s5'), slotDoc()));

    // Players can see slots; nobody can mark one booked from the app.
    await assertSucceeds(getDoc(doc(db(env, 'sita'), 'venues/hari/slots/s1')));
    await assertFails(updateDoc(doc(fs, 'venues/hari/slots/s1'), { status: 'booked' }));
    await assertFails(updateDoc(doc(db(env, 'sita'), 'venues/hari/slots/s1'), { status: 'booked' }));
    await assertSucceeds(updateDoc(doc(fs, 'venues/hari/slots/s1'), { price: 1800 }));

    // A booked slot can't be edited or deleted by the owner (use cancel).
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'venues/hari/slots/s1'), { status: 'booked' }),
    );
    await assertFails(deleteDoc(doc(fs, 'venues/hari/slots/s1')));
    await assertFails(updateDoc(doc(fs, 'venues/hari/slots/s1'), { price: 1 }));
  });

  describe('venue ratings', () => {
    const rating = (over = {}) => ({
      matchId: 'm1',
      reviewerId: 'amit',
      overall: 4,
      pitch: 5,
      facilities: 3,
      value: 4,
      comment: 'Nice',
      reviewer: { name: 'Amit Karki', photoUrl: null },
      matchTitle: 'Friday Futsal',
      createdAt: serverTimestamp(),
      ...over,
    });

    async function seedMatch(over = {}) {
      await seedOwner('hari');
      await env.withSecurityRulesDisabled(async (ctx) => {
        const fs = ctx.firestore();
        await setDoc(doc(fs, 'players/amit'), profileDoc({ fullName: 'Amit Karki', username: 'amit' }));
        await setDoc(doc(fs, 'players/sita'), profileDoc({ fullName: 'Sita Rai', username: 'sita' }));
        await setDoc(doc(fs, 'matches/m1'), {
          organizer: { uid: 'raj' },
          title: 'Friday Futsal',
          venue: { name: 'Dhuku Futsal', venueId: 'hari' },
          status: 'completed',
          endAt: at(-2 * HOUR),
          ...over,
        });
        await setDoc(doc(fs, 'matches/m1/roster/amit'), { player: { uid: 'amit' } });
      });
    }

    test('a player who was there rates once', async () => {
      await seedMatch();
      const ref = doc(db(env, 'amit'), 'venues/hari/ratings/m1_amit');
      await assertSucceeds(setDoc(ref, rating()));
      await assertFails(updateDoc(ref, { overall: 1 }));
    });

    test('not there, wrong venue, not finished, too late or bad scores', async () => {
      await seedMatch();
      // Sita wasn't on the roster.
      await assertFails(
        setDoc(
          doc(db(env, 'sita'), 'venues/hari/ratings/m1_sita'),
          rating({ reviewerId: 'sita', reviewer: { name: 'Sita Rai', photoUrl: null } }),
        ),
      );
      const amit = db(env, 'amit');
      await assertFails(setDoc(doc(amit, 'venues/hari/ratings/m1_amit'), rating({ pitch: 6 })));
      await assertFails(setDoc(doc(amit, 'venues/hari/ratings/m1_amit'), rating({ overall: 0 })));
      await assertFails(setDoc(doc(amit, 'venues/hari/ratings/other_amit'), rating()));
      await assertFails(
        setDoc(doc(amit, 'venues/hari/ratings/m1_amit'), rating({ reviewer: { name: 'Someone', photoUrl: null } })),
      );

      await env.withSecurityRulesDisabled((ctx) =>
        updateDoc(doc(ctx.firestore(), 'matches/m1'), { status: 'started' }),
      );
      await assertFails(setDoc(doc(amit, 'venues/hari/ratings/m1_amit'), rating()));

      await env.withSecurityRulesDisabled((ctx) =>
        updateDoc(doc(ctx.firestore(), 'matches/m1'), { status: 'completed', endAt: at(-15 * 24 * HOUR) }),
      );
      await assertFails(setDoc(doc(amit, 'venues/hari/ratings/m1_amit'), rating()));
    });

    test('a match typed in by hand (no venueId) cannot rate a venue', async () => {
      await seedMatch({ venue: { name: 'Dhuku Futsal' } });
      await assertFails(setDoc(doc(db(env, 'amit'), 'venues/hari/ratings/m1_amit'), rating()));
    });
  });
});
