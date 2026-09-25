import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collectionGroup,
  doc,
  getDocs,
  query,
  setDoc,
  where,
} from 'firebase/firestore';
import { createTestEnv, db } from './helpers.mjs';

describe('My matches: requests across matches', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      for (const [match, uid] of [['m1', 'amit'], ['m2', 'amit'], ['m1', 'sita']]) {
        await setDoc(doc(fs, `matches/${match}`), { organizer: { uid: 'raj' } });
        await setDoc(doc(fs, `matches/${match}/requests/${uid}`), {
          status: 'pending',
          player: { uid },
        });
      }
    });
  });

  test('a player can list their own requests in every match', async () => {
    const fs = db(env, 'amit');
    const q = query(collectionGroup(fs, 'requests'), where('player.uid', '==', 'amit'));
    const snap = await assertSucceeds(getDocs(q));
    if (snap.size !== 2) throw new Error(`expected 2 requests, got ${snap.size}`);
  });

  test("cannot list someone else's requests", async () => {
    const fs = db(env, 'amit');
    await assertFails(
      getDocs(query(collectionGroup(fs, 'requests'), where('player.uid', '==', 'sita'))),
    );
  });

  test('cannot list all requests without filtering to yourself', async () => {
    await assertFails(getDocs(collectionGroup(db(env, 'amit'), 'requests')));
  });
});
