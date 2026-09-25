import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';
import { createTestEnv, db, profileDoc } from './helpers.mjs';

/** Creates profile + username claim atomically, like the app does. */
function createProfile(firestore, uid, overrides = {}) {
  const data = profileDoc(overrides);
  const batch = writeBatch(firestore);
  batch.set(doc(firestore, 'usernames', data.username), { uid });
  batch.set(doc(firestore, 'players', uid), data);
  return batch.commit();
}

describe('players + usernames', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  test('player can create their profile with a username claim', async () => {
    await assertSucceeds(createProfile(db(env, 'raj'), 'raj'));
  });

  test('cannot create a profile without claiming the username', async () => {
    const firestore = db(env, 'raj');
    await assertFails(setDoc(doc(firestore, 'players', 'raj'), profileDoc()));
  });

  test('cannot claim a username someone else holds', async () => {
    await createProfile(db(env, 'raj'), 'raj');
    await assertFails(createProfile(db(env, 'amit'), 'amit'));
  });

  test("cannot create someone else's profile", async () => {
    await assertFails(createProfile(db(env, 'raj'), 'amit'));
  });

  test('cannot set stats on create', async () => {
    await assertFails(
      createProfile(db(env, 'raj'), 'raj', {
        stats: { gamesPlayed: 100, ratingAvg: 5 },
      }),
    );
  });

  test('rejects under-16 date of birth', async () => {
    const tooYoung = new Date();
    tooYoung.setFullYear(tooYoung.getFullYear() - 14);
    await assertFails(
      createProfile(db(env, 'raj'), 'raj', {
        dateOfBirth: Timestamp.fromDate(tooYoung),
      }),
    );
  });

  test('rejects invalid positions and usernames', async () => {
    await assertFails(
      createProfile(db(env, 'raj'), 'raj', { primaryPosition: 'libero' }),
    );
    await assertFails(
      createProfile(db(env, 'amit'), 'amit', { username: 'Bad Name!' }),
    );
  });

  test('a player cannot claim a second username later', async () => {
    const firestore = db(env, 'raj');
    await createProfile(firestore, 'raj');
    await assertFails(
      setDoc(doc(firestore, 'usernames', 'raj_alt'), { uid: 'raj' }),
    );
  });

  test('owner can update editable fields', async () => {
    const firestore = db(env, 'raj');
    await createProfile(firestore, 'raj');
    await assertSucceeds(
      updateDoc(doc(firestore, 'players', 'raj'), {
        city: 'Lalitpur',
        bio: 'Box-to-box midfielder',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('owner cannot change username or stats', async () => {
    const firestore = db(env, 'raj');
    await createProfile(firestore, 'raj');
    const ref = doc(firestore, 'players', 'raj');
    await assertFails(
      updateDoc(ref, { username: 'someone', updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(ref, {
        stats: { ratingAvg: 5 },
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test("cannot update another player's profile", async () => {
    await createProfile(db(env, 'raj'), 'raj');
    await assertFails(
      updateDoc(doc(db(env, 'amit'), 'players', 'raj'), {
        city: 'Pokhara',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('signed-in users can read profiles; signed-out cannot', async () => {
    await createProfile(db(env, 'raj'), 'raj');
    await assertSucceeds(getDoc(doc(db(env, 'amit'), 'players', 'raj')));
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, 'players', 'raj')));
  });

  test('username availability can be checked', async () => {
    await assertSucceeds(getDoc(doc(db(env, 'raj'), 'usernames', 'free_name')));
  });
});

describe('users (private)', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  test('owner can write own email and read it back', async () => {
    const firestore = db(env, 'raj', 'raj@example.com');
    const ref = doc(firestore, 'users', 'raj');
    await assertSucceeds(
      setDoc(ref, { email: 'raj@example.com', createdAt: serverTimestamp() }),
    );
    await assertSucceeds(getDoc(ref));
  });

  test('cannot store an email that is not yours', async () => {
    const firestore = db(env, 'raj', 'raj@example.com');
    await assertFails(
      setDoc(doc(firestore, 'users', 'raj'), { email: 'boss@example.com' }),
    );
  });

  test("cannot read another user's private doc", async () => {
    await assertFails(getDoc(doc(db(env, 'amit'), 'users', 'raj')));
  });
});
