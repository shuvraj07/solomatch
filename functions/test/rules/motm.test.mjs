import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnv, db } from './helpers.mjs';

const HOUR = 60 * 60 * 1000;

describe('Man of the Match votes', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  async function seedMatch(overrides = {}) {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'matches/m1'), {
        organizer: { uid: 'org' },
        status: 'completed',
        votingClosesAt: Timestamp.fromMillis(Date.now() + HOUR),
        ...overrides,
      });
      for (const uid of ['raj', 'amit']) {
        await setDoc(doc(fs, `matches/m1/roster/${uid}`), { group: 'any' });
      }
    });
  }

  beforeEach(async () => {
    await env.clearFirestore();
    await seedMatch();
  });

  const vote = (voter, nomineeId) =>
    setDoc(doc(db(env, voter), `matches/m1/motm_votes/${voter}`), {
      nomineeId,
      votedAt: serverTimestamp(),
    });

  test('a roster player can vote for a teammate and change it', async () => {
    await assertSucceeds(vote('raj', 'amit'));
    await assertSucceeds(vote('raj', 'amit'));
  });

  test('the organizer can vote too', async () => {
    await assertSucceeds(vote('org', 'raj'));
  });

  test('cannot vote for yourself or a non-roster player', async () => {
    await assertFails(vote('raj', 'raj'));
    await assertFails(vote('raj', 'stranger'));
  });

  test('people who were not there cannot vote', async () => {
    await assertFails(vote('stranger', 'raj'));
  });

  test("cannot cast someone else's vote", async () => {
    await assertFails(
      setDoc(doc(db(env, 'raj'), 'matches/m1/motm_votes/amit'), {
        nomineeId: 'raj',
        votedAt: serverTimestamp(),
      }),
    );
  });

  test('only after the match and before voting closes', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'matches/m1'), { status: 'started' }),
    );
    await assertFails(vote('raj', 'amit'));

    await seedMatch({ votingClosesAt: Timestamp.fromMillis(Date.now() - 1000) });
    await assertFails(vote('raj', 'amit'));
  });

  test('votes are private to the voter', async () => {
    await vote('raj', 'amit');
    await assertSucceeds(getDoc(doc(db(env, 'raj'), 'matches/m1/motm_votes/raj')));
    await assertFails(getDoc(doc(db(env, 'amit'), 'matches/m1/motm_votes/raj')));
    await assertFails(getDoc(doc(db(env, 'org'), 'matches/m1/motm_votes/raj')));
  });
});
