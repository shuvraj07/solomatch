// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import { applyReview } from '../../lib/reviews/aggregate.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'review-tests');
const db = getFirestore(app);

const stats = async (uid) => (await db.doc(`players/${uid}`).get()).data().stats ?? {};

async function addReview(id, rating, comment = '') {
  await db.doc(`reviews/${id}`).set({
    matchId: 'm1',
    reviewerId: id.split('_')[1],
    revieweeId: 'amit',
    rating,
    comment,
    reviewer: { name: 'Raj', photoUrl: null },
    matchTitle: 'Saturday Night Football',
  });
  return applyReview(db, id);
}

async function clearAll() {
  await db.recursiveDelete(db.collection('reviews'));
  await db.recursiveDelete(db.collection('players'));
}

describe('applyReview', () => {
  beforeEach(async () => {
    await clearAll();
    await db.doc('players/amit').set({ fullName: 'Amit Karki' });
  });
  after(clearAll);

  test('updates count, sum and average; notifies the player', async () => {
    const note = await addReview('m1_raj_amit', 5, 'Great keeper');
    await addReview('m1_sita_amit', 4);
    await addReview('m1_hari_amit', 4);

    assert.deepEqual(await stats('amit'), { ratingCount: 3, ratingSum: 13, ratingAvg: 4.33 });
    assert.equal(note.uid, 'amit');
    assert.equal(note.type, 'new_review');
    assert.equal(note.title, 'Raj rated you ⭐⭐⭐⭐⭐');
    assert.match(note.body, /"Great keeper" · Saturday Night Football/);
  });

  test('a retried trigger never counts a review twice', async () => {
    await addReview('m1_raj_amit', 5);
    assert.equal(await applyReview(db, 'm1_raj_amit'), null);
    await Promise.all([applyReview(db, 'm1_raj_amit'), applyReview(db, 'm1_raj_amit')]);
    assert.deepEqual(await stats('amit'), { ratingCount: 1, ratingSum: 5, ratingAvg: 5 });
  });

  test('works from an existing average without a stored sum', async () => {
    await db.doc('players/amit').set({ stats: { ratingAvg: 4, ratingCount: 2 } }, { merge: true });
    await addReview('m1_raj_amit', 1);
    assert.deepEqual(await stats('amit'), { ratingAvg: 3, ratingCount: 3, ratingSum: 9 });
  });
});
