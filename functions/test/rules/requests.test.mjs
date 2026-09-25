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
import { createTestEnv, db, profileDoc } from './helpers.mjs';

const START = Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000));

/** Player card copied from the player's profile (see validPlayerCard). */
function card(uid, overrides = {}) {
  return {
    uid,
    name: 'Amit Karki',
    username: uid,
    photoUrl: null,
    primaryPosition: 'centralMidfielder',
    secondaryPositions: ['attackingMidfielder'],
    skillLevel: 'intermediate',
    ratingAvg: 0,
    ratingCount: 0,
    gamesPlayed: 0,
    ...overrides,
  };
}

function requestDoc(uid, overrides = {}) {
  return {
    status: 'pending',
    player: card(uid),
    preferredGroup: 'mid',
    message: '',
    match: { title: 'Saturday Night Football', startAt: START, venueName: 'Dhuku Futsal' },
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

describe('join requests + roster', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'players/amit'), profileDoc({ fullName: 'Amit Karki', username: 'amit' }));
      await setDoc(doc(fs, 'players/raj'), profileDoc());
      await setDoc(doc(fs, 'matches/m1'), {
        organizer: { uid: 'raj', name: 'Raj Shrestha', username: 'raj10', photoUrl: null },
        title: 'Saturday Night Football',
        venue: { name: 'Dhuku Futsal', city: 'Kathmandu' },
        status: 'published',
        startAt: START,
        maxPlayers: 10,
        currentPlayers: 0,
      });
      await setDoc(doc(fs, 'matches/m1/roster/sita'), { group: 'gk' });
    });
  });

  const ask = (uid, overrides) =>
    setDoc(doc(db(env, uid), 'matches/m1/requests', uid), requestDoc(uid, overrides));

  test('a player can request to join', async () => {
    await assertSucceeds(ask('amit'));
  });

  test('cannot request on behalf of someone else', async () => {
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'matches/m1/requests/sita'), requestDoc('sita')),
    );
  });

  test('cannot fake rating, games played or position on the card', async () => {
    await assertFails(ask('amit', { player: card('amit', { ratingAvg: 5, ratingCount: 40 }) }));
    await assertFails(ask('amit', { player: card('amit', { gamesPlayed: 99 }) }));
    await assertFails(ask('amit', { player: card('amit', { primaryPosition: 'striker' }) }));
  });

  test('cannot request as already accepted', async () => {
    await assertFails(ask('amit', { status: 'accepted' }));
  });

  test('organizer cannot request their own match', async () => {
    await assertFails(
      setDoc(
        doc(db(env, 'raj'), 'matches/m1/requests/raj'),
        requestDoc('raj', {
          player: card('raj', { name: 'Raj Shrestha', username: 'raj10' }),
        }),
      ),
    );
  });

  test('cannot request a full, cancelled or started match', async () => {
    for (const change of [
      { status: 'full' },
      { status: 'cancelled' },
      { startAt: Timestamp.fromDate(new Date(Date.now() - 1000)) },
    ]) {
      await env.withSecurityRulesDisabled((ctx) =>
        updateDoc(doc(ctx.firestore(), 'matches/m1'), change),
      );
      await assertFails(
        ask('amit', change.startAt ? { match: { ...requestDoc('amit').match, startAt: change.startAt } } : {}),
      );
      await env.withSecurityRulesDisabled((ctx) =>
        updateDoc(doc(ctx.firestore(), 'matches/m1'), { status: 'published', startAt: START }),
      );
    }
  });

  test('player and organizer can read the request; others cannot', async () => {
    await ask('amit');
    await assertSucceeds(getDoc(doc(db(env, 'amit'), 'matches/m1/requests/amit')));
    await assertSucceeds(getDoc(doc(db(env, 'raj'), 'matches/m1/requests/amit')));
    await assertFails(getDoc(doc(db(env, 'sita'), 'matches/m1/requests/amit')));
  });

  test('player can withdraw a pending request and ask again', async () => {
    await ask('amit');
    const ref = doc(db(env, 'amit'), 'matches/m1/requests/amit');
    await assertSucceeds(
      updateDoc(ref, { status: 'cancelled', updatedAt: serverTimestamp() }),
    );
    await assertSucceeds(ask('amit'));
  });

  test('nobody can accept or reject from the client (server only)', async () => {
    await ask('amit');
    await assertFails(
      updateDoc(doc(db(env, 'amit'), 'matches/m1/requests/amit'), {
        status: 'accepted',
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(
      updateDoc(doc(db(env, 'raj'), 'matches/m1/requests/amit'), {
        status: 'accepted',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('rejection is final', async () => {
    await ask('amit');
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'matches/m1/requests/amit'), { status: 'rejected' }),
    );
    await assertFails(ask('amit'));
  });

  test('roster is readable but only the server writes it', async () => {
    await assertSucceeds(getDoc(doc(db(env, 'amit'), 'matches/m1/roster/sita')));
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'matches/m1/roster/amit'), { group: 'mid' }),
    );
    await assertFails(
      setDoc(doc(db(env, 'raj'), 'matches/m1/roster/amit'), { group: 'mid' }),
    );
  });
});
