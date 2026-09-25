import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnv, db } from './helpers.mjs';

const MIN = 60 * 1000;
const at = (ms) => Timestamp.fromMillis(Date.now() + ms);

const goal = (over = {}) => ({
  type: 'goal',
  team: 'home',
  playerUid: 'amit',
  playerName: 'Amit Karki',
  minute: 12,
  by: 'raj',
  createdAt: serverTimestamp(),
  ...over,
});

describe('live match center', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  const seedMatch = (over = {}) =>
    env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'matches/m1'), {
        organizer: { uid: 'raj' },
        title: 'Friday Futsal',
        status: 'started',
        startAt: at(-20 * MIN),
        endAt: at(40 * MIN),
        ...over,
      }),
    );

  test('organizer posts goals and cards during the match; everyone can watch', async () => {
    await seedMatch();
    const events = collection(db(env, 'raj'), 'matches/m1/events');
    const ref = await assertSucceeds(addDoc(events, goal()));
    await assertSucceeds(addDoc(events, goal({ type: 'yellow', team: 'away' })));
    await assertSucceeds(addDoc(events, goal({ playerUid: null, playerName: '' })));
    await assertSucceeds(getDocs(collection(db(env, 'fan'), 'matches/m1/events')));
    // Undo.
    await assertSucceeds(deleteDoc(ref));
  });

  test('only the organizer, only valid events, never edited', async () => {
    await seedMatch();
    await assertFails(
      addDoc(collection(db(env, 'amit'), 'matches/m1/events'), goal({ by: 'amit' })),
    );
    const events = collection(db(env, 'raj'), 'matches/m1/events');
    await assertFails(addDoc(events, goal({ type: 'penalty' })));
    await assertFails(addDoc(events, goal({ team: 'both' })));
    await assertFails(addDoc(events, goal({ minute: -1 })));
    await assertFails(addDoc(events, goal({ by: 'someone' })));
    const ref = await assertSucceeds(addDoc(events, goal()));
    await assertFails(updateDoc(ref, { team: 'away' }));
  });

  test('not long before kick-off, not hours after, not when cancelled', async () => {
    await seedMatch({ status: 'published', startAt: at(60 * MIN), endAt: at(120 * MIN) });
    await assertFails(addDoc(collection(db(env, 'raj'), 'matches/m1/events'), goal()));

    await seedMatch({ status: 'completed', startAt: at(-300 * MIN), endAt: at(-240 * MIN) });
    await assertFails(addDoc(collection(db(env, 'raj'), 'matches/m1/events'), goal()));

    // Late entry just after the final whistle is fine.
    await seedMatch({ status: 'completed', startAt: at(-90 * MIN), endAt: at(-30 * MIN) });
    await assertSucceeds(addDoc(collection(db(env, 'raj'), 'matches/m1/events'), goal()));

    await seedMatch({ status: 'cancelled' });
    await assertFails(addDoc(collection(db(env, 'raj'), 'matches/m1/events'), goal()));
  });

  test('team names: organizer only, 1–30 characters, score stays server-only', async () => {
    await seedMatch();
    const ref = doc(db(env, 'raj'), 'matches/m1');
    const names = (home, away) => ({ teams: { home, away }, updatedAt: serverTimestamp() });
    await assertSucceeds(updateDoc(ref, names('Tigers', 'Eagles')));
    await assertFails(updateDoc(ref, names('', 'Eagles')));
    await assertFails(updateDoc(ref, names('x'.repeat(31), 'y')));
    await assertFails(updateDoc(ref, { score: { home: 9, away: 0 }, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db(env, 'amit'), 'matches/m1'), names('A', 'B')));
  });

  test('anyone can follow and unfollow for themselves', async () => {
    await seedMatch();
    const mine = doc(db(env, 'fan'), 'matches/m1/followers/fan');
    await assertSucceeds(setDoc(mine, { createdAt: serverTimestamp() }));
    await assertFails(
      setDoc(doc(db(env, 'fan'), 'matches/m1/followers/other'), { createdAt: serverTimestamp() }),
    );
    await assertFails(getDocs(collection(db(env, 'fan'), 'matches/m1/followers')));
    await assertSucceeds(deleteDoc(mine));
  });
});
