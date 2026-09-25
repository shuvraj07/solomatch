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

const DAY = 24 * 60 * 60 * 1000;

describe('reviews', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  async function seed({ status = 'completed', endedDaysAgo = 1 } = {}) {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'players/amit'), profileDoc({ fullName: 'Amit Karki', username: 'amit' }));
      await setDoc(doc(fs, 'players/raj'), profileDoc());
      await setDoc(doc(fs, 'matches/m1'), {
        organizer: { uid: 'raj' },
        title: 'Saturday Night Football',
        status,
        endAt: Timestamp.fromMillis(Date.now() - endedDaysAgo * DAY),
      });
      for (const uid of ['amit', 'sita']) {
        await setDoc(doc(fs, `matches/m1/roster/${uid}`), { group: 'any' });
      }
    });
  }

  beforeEach(async () => {
    await env.clearFirestore();
    await seed();
  });

  const review = (reviewer, reviewee, over = {}) => ({
    matchId: 'm1',
    reviewerId: reviewer,
    revieweeId: reviewee,
    rating: 5,
    comment: 'Great keeper',
    reviewer: reviewer === 'amit'
      ? { name: 'Amit Karki', photoUrl: null }
      : { name: 'Raj Shrestha', photoUrl: null },
    matchTitle: 'Saturday Night Football',
    createdAt: serverTimestamp(),
    ...over,
  });

  const submit = (reviewer, reviewee, over, id = `m1_${reviewer}_${reviewee}`) =>
    setDoc(doc(db(env, reviewer), 'reviews', id), review(reviewer, reviewee, over));

  test('players rate teammates and the organizer; organizer rates players', async () => {
    await assertSucceeds(submit('amit', 'sita'));
    await assertSucceeds(submit('amit', 'raj'));
    await assertSucceeds(submit('raj', 'amit'));
  });

  test('anyone signed in can read reviews', async () => {
    await submit('amit', 'sita');
    await assertSucceeds(getDoc(doc(db(env, 'stranger'), 'reviews/m1_amit_sita')));
  });

  test('once per pair: no second review, no edits, no deletes', async () => {
    await submit('amit', 'sita');
    await assertFails(submit('amit', 'sita', { rating: 1 }));
    const ref = doc(db(env, 'amit'), 'reviews/m1_amit_sita');
    await assertFails(updateDoc(ref, { rating: 1 }));
    await assertFails(deleteDoc(ref));
  });

  test('cannot rate yourself, someone not there, or as someone else', async () => {
    await assertFails(submit('amit', 'amit'));
    await assertFails(submit('amit', 'stranger'));
    await assertFails(submit('stranger', 'amit', { reviewer: { name: 'X', photoUrl: null } }));
    await assertFails(submit('amit', 'sita', { reviewerId: 'sita' }, 'm1_amit_sita'));
    await assertFails(submit('amit', 'sita', {}, 'custom-id'));
  });

  test('rating 1–5, comment ≤ 300, real reviewer name', async () => {
    await assertFails(submit('amit', 'sita', { rating: 6 }));
    await assertFails(submit('amit', 'sita', { rating: 0 }));
    await assertFails(submit('amit', 'sita', { rating: 4.5 }));
    await assertFails(submit('amit', 'sita', { comment: 'x'.repeat(301) }));
    await assertFails(submit('amit', 'sita', { reviewer: { name: 'Messi', photoUrl: null } }));
  });

  test('only after the match, and within 7 days', async () => {
    await seed({ status: 'started' });
    await assertFails(submit('amit', 'sita'));
    await seed({ endedDaysAgo: 8 });
    await assertFails(submit('amit', 'sita'));
  });

  test('clients cannot mark a review as counted', async () => {
    await assertFails(submit('amit', 'sita', { counted: true }));
  });
});
