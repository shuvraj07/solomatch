import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnv, db } from './helpers.mjs';

describe('devices + notification inbox', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'users/amit/notifications/n1'), {
        type: 'request_accepted',
        title: "You're in!",
        body: 'x',
        matchId: 'm1',
        read: false,
      }),
    );
  });

  const device = (uid, owner = uid) =>
    setDoc(doc(db(env, uid), `users/${owner}/devices/token-abc`), {
      platform: 'android',
      updatedAt: serverTimestamp(),
    });

  test('a user registers and removes their own device token', async () => {
    await assertSucceeds(device('amit'));
    await assertSucceeds(deleteDoc(doc(db(env, 'amit'), 'users/amit/devices/token-abc')));
  });

  test("cannot register a device on someone else's account", async () => {
    await assertFails(device('amit', 'raj'));
  });

  test('reads own inbox and marks read; nothing else', async () => {
    const fs = db(env, 'amit');
    await assertSucceeds(getDocs(collection(fs, 'users/amit/notifications')));
    const ref = doc(fs, 'users/amit/notifications/n1');
    await assertFails(updateDoc(ref, { title: 'Hacked' }));
    await assertSucceeds(updateDoc(ref, { read: true }));
  });

  test("cannot read or write another user's inbox, or fake notifications", async () => {
    await assertFails(getDocs(collection(db(env, 'raj'), 'users/amit/notifications')));
    await assertFails(
      setDoc(doc(db(env, 'raj'), 'users/amit/notifications/fake'), {
        type: 'request_accepted',
        read: false,
      }),
    );
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'users/amit/notifications/self'), {
        type: 'request_accepted',
        read: false,
      }),
    );
  });
});
