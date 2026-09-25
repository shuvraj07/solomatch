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
} from 'firebase/firestore';
import { createTestEnv, db, profileDoc } from './helpers.mjs';

const HOUR = 60 * 60 * 1000;

/** A valid `matches/{id}` payload, matching MatchMapper.newMatch. */
function matchDoc(overrides = {}) {
  const start = new Date(Date.now() + 24 * HOUR);
  return {
    organizer: { uid: 'raj', name: 'Raj Shrestha', username: 'raj10', photoUrl: null },
    title: 'Saturday Night Football',
    searchTitle: 'saturday night football',
    venue: {
      name: 'Dhuku Futsal',
      address: 'Baneshwor',
      city: 'Kathmandu',
      placeId: null,
      lat: null,
      lng: null,
    },
    startAt: Timestamp.fromDate(start),
    endAt: Timestamp.fromDate(new Date(start.getTime() + 2 * HOUR)),
    format: 'fiveASide',
    maxPlayers: 10,
    currentPlayers: 0,
    spotsRemaining: 10,
    slots: {
      gk: { needed: 1, filled: 0 },
      def: { needed: 2, filled: 0 },
      mid: { needed: 1, filled: 0 },
      fwd: { needed: 1, filled: 0 },
      any: { needed: 5, filled: 0 },
    },
    skillLevel: 'any',
    price: { amount: 0, currency: 'NPR', isFree: true },
    isIndoor: false,
    description: '',
    rules: '',
    photos: [],
    status: 'published',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

describe('matches', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    // Organizer profile, written bypassing rules.
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'players/raj'), profileDoc());
    });
  });

  const publish = (overrides, uid = 'raj') =>
    setDoc(doc(db(env, uid), 'matches', 'm1'), matchDoc(overrides));

  test('organizer can publish a valid match', async () => {
    await assertSucceeds(publish());
  });

  test('signed-in players can read matches; signed-out cannot', async () => {
    await publish();
    await assertSucceeds(getDoc(doc(db(env, 'amit'), 'matches', 'm1')));
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, 'matches', 'm1')));
  });

  test('cannot publish as someone else', async () => {
    await assertFails(publish({}, 'amit'));
  });

  test('cannot fake the organizer username', async () => {
    await assertFails(
      publish({
        organizer: { uid: 'raj', name: 'Raj', username: 'famous_player', photoUrl: null },
      }),
    );
  });

  test('cannot start with players already counted', async () => {
    await assertFails(publish({ currentPlayers: 3, spotsRemaining: 7 }));
    await assertFails(
      publish({
        slots: { ...matchDoc().slots, gk: { needed: 1, filled: 1 } },
      }),
    );
  });

  test('position slots must add up to maxPlayers', async () => {
    await assertFails(
      publish({ slots: { ...matchDoc().slots, any: { needed: 9, filled: 0 } } }),
    );
  });

  test('rejects matches in the past or with bad durations', async () => {
    const past = new Date(Date.now() - HOUR);
    await assertFails(
      publish({
        startAt: Timestamp.fromDate(past),
        endAt: Timestamp.fromDate(new Date(past.getTime() + HOUR)),
      }),
    );
    const start = new Date(Date.now() + 24 * HOUR);
    await assertFails(
      publish({
        startAt: Timestamp.fromDate(start),
        endAt: Timestamp.fromDate(new Date(start.getTime() + 8 * HOUR)),
      }),
    );
  });

  test('rejects invalid capacity, price and status', async () => {
    await assertFails(publish({ maxPlayers: 50, spotsRemaining: 50 }));
    await assertFails(
      publish({ price: { amount: -5, currency: 'NPR', isFree: false } }),
    );
    await assertFails(publish({ status: 'full' }));
  });

  test('organizer can edit text and cancel; not capacity or counters', async () => {
    await publish();
    const ref = doc(db(env, 'raj'), 'matches', 'm1');
    await assertSucceeds(
      updateDoc(ref, {
        description: 'Bring a light and a dark shirt',
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(
      updateDoc(ref, { currentPlayers: 10, updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(ref, { maxPlayers: 30, updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(ref, { status: 'full', updatedAt: serverTimestamp() }),
    );
    await assertSucceeds(
      updateDoc(ref, { status: 'cancelled', updatedAt: serverTimestamp() }),
    );
  });

  test('other players cannot edit or cancel', async () => {
    await publish();
    const ref = doc(db(env, 'amit'), 'matches', 'm1');
    await assertFails(
      updateDoc(ref, { status: 'cancelled', updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(ref, { title: 'Hijacked', searchTitle: 'hijacked', updatedAt: serverTimestamp() }),
    );
  });

  test('nobody can delete a match', async () => {
    await publish();
    await assertFails(deleteDoc(doc(db(env, 'raj'), 'matches', 'm1')));
  });
});

describe('match_drafts', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  const draft = (organizerId) => ({
    organizerId,
    title: 'Half-finished',
    description: '',
    rules: '',
    photos: [],
    updatedAt: serverTimestamp(),
  });

  test('organizer can save, read and delete their draft', async () => {
    const ref = doc(db(env, 'raj'), 'match_drafts', 'd1');
    await assertSucceeds(setDoc(ref, draft('raj')));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(deleteDoc(ref));
  });

  test('drafts are private', async () => {
    await setDoc(doc(db(env, 'raj'), 'match_drafts', 'd1'), draft('raj'));
    const other = doc(db(env, 'amit'), 'match_drafts', 'd1');
    await assertFails(getDoc(other));
    await assertFails(setDoc(other, draft('amit')));
    await assertFails(deleteDoc(other));
  });

  test("cannot create a draft for someone else", async () => {
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'match_drafts', 'd2'), draft('raj')),
    );
  });
});
