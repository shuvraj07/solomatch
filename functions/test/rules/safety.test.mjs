import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnv, db, profileDoc } from './helpers.mjs';

describe('safety, settings and privacy', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());
  beforeEach(() => env.clearFirestore());

  test('notification settings: own doc, known toggles, booleans only', async () => {
    const ref = doc(db(env, 'amit'), 'users/amit');
    await assertSucceeds(setDoc(ref, { notificationPrefs: { chat: false, matches: true } }, { merge: true }));
    await assertFails(setDoc(ref, { notificationPrefs: { chat: 'off' } }, { merge: true }));
    await assertFails(setDoc(ref, { notificationPrefs: { marketing: true } }, { merge: true }));
    await assertFails(
      setDoc(doc(db(env, 'raj'), 'users/amit'), { notificationPrefs: { chat: false } }, { merge: true }),
    );
  });

  test('block list is private and you cannot block yourself', async () => {
    const mine = doc(db(env, 'amit'), 'users/amit/blocks/sita');
    await assertSucceeds(setDoc(mine, { name: 'Sita Rai', createdAt: serverTimestamp() }));
    await assertSucceeds(getDocs(collection(db(env, 'amit'), 'users/amit/blocks')));
    await assertFails(getDoc(doc(db(env, 'sita'), 'users/amit/blocks/sita')));
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'users/amit/blocks/amit'), { name: 'me', createdAt: serverTimestamp() }),
    );
    await assertSucceeds(deleteDoc(mine));
  });

  test("a blocked player cannot request to join the blocker's match", async () => {
    const start = Timestamp.fromMillis(Date.now() + 86400000);
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'players/amit'), profileDoc({ fullName: 'Amit Karki', username: 'amit' }));
      await setDoc(doc(fs, 'matches/m1'), {
        organizer: { uid: 'raj' },
        title: 'T',
        venue: { name: 'V' },
        status: 'published',
        startAt: start,
      });
      await setDoc(doc(fs, 'users/raj/blocks/amit'), { name: 'Amit' });
    });
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'matches/m1/requests/amit'), {
        status: 'pending',
        player: {
          uid: 'amit', name: 'Amit Karki', username: 'amit', photoUrl: null,
          primaryPosition: 'centralMidfielder', secondaryPositions: ['attackingMidfielder'],
          skillLevel: 'intermediate', ratingAvg: 0, ratingCount: 0, gamesPlayed: 0,
        },
        preferredGroup: 'mid',
        message: '',
        match: { title: 'T', startAt: start, venueName: 'V' },
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('reports: anyone can file one; only admins can read', async () => {
    const report = {
      reporterId: 'amit',
      targetType: 'player',
      targetId: 'sita',
      targetName: 'Sita Rai',
      reason: 'no_show',
      details: 'Did not turn up twice',
      status: 'open',
      createdAt: serverTimestamp(),
    };
    const ref = await assertSucceeds(addDoc(collection(db(env, 'amit'), 'reports'), report));
    await assertFails(getDoc(doc(db(env, 'amit'), ref.path)));
    const admin = env.authenticatedContext('admin1', { admin: true }).firestore();
    await assertSucceeds(getDoc(doc(admin, ref.path)));
    await assertFails(addDoc(collection(db(env, 'amit'), 'reports'), { ...report, reporterId: 'sita' }));
    await assertFails(addDoc(collection(db(env, 'amit'), 'reports'), { ...report, targetId: 'amit' }));
    await assertFails(addDoc(collection(db(env, 'amit'), 'reports'), { ...report, reason: 'dislike' }));
    await assertFails(addDoc(collection(db(env, 'amit'), 'reports'), { ...report, status: 'resolved' }));
  });

  test('profile privacy: hideCity can be set; nothing else sneaks in', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'players/amit'), profileDoc({ username: 'amit' })),
    );
    const ref = doc(db(env, 'amit'), 'players/amit');
    await assertSucceeds(updateDoc(ref, { privacy: { hideCity: true }, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { privacy: { verified: true }, updatedAt: serverTimestamp() }));
  });
});
