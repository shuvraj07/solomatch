// Runs against the Firestore emulator (see `npm run test:functions`).
import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import {
  acceptRequest,
  leaveMatch,
  rejectRequest,
} from '../../lib/requests/join_requests.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'join-tests');
const db = getFirestore(app);
const HOUR = 60 * 60 * 1000;

const player = (uid) => ({ uid, name: uid, username: uid, photoUrl: null });

/**
 * Seeds `matches/m1` with [accepted] players already on the roster and a
 * pending request for each uid in [pending].
 */
async function seed({
  maxPlayers = 10,
  accepted = 0,
  pending = [],
  slots,
  startAt = new Date(Date.now() + 24 * HOUR),
} = {}) {
  const match = db.doc('matches/m1');
  const batch = db.batch();
  batch.set(match, {
    organizer: player('org'),
    title: 'Test match',
    maxPlayers,
    currentPlayers: accepted,
    spotsRemaining: maxPlayers - accepted,
    status: accepted === 0 ? 'published' : accepted >= maxPlayers ? 'full' : 'filling',
    startAt: Timestamp.fromDate(startAt),
    slots: slots ?? {
      gk: { needed: 1, filled: 0 },
      def: { needed: 2, filled: 0 },
      mid: { needed: 1, filled: 0 },
      fwd: { needed: 1, filled: 0 },
      any: { needed: maxPlayers - 5, filled: accepted },
    },
  });
  for (let i = 0; i < accepted; i++) {
    batch.set(match.collection('roster').doc(`old${i}`), {
      player: player(`old${i}`),
      group: 'any',
    });
  }
  for (const uid of pending) {
    batch.set(match.collection('requests').doc(uid), {
      status: 'pending',
      player: player(uid),
      preferredGroup: 'mid',
    });
  }
  await batch.commit();
}

const matchData = async () => (await db.doc('matches/m1').get()).data();
const requestStatus = async (uid) =>
  (await db.doc(`matches/m1/requests/${uid}`).get()).data()?.status;
const rosterSize = async () =>
  (await db.collection('matches/m1/roster').count().get()).data().count;

async function rejects(promise, code, messagePart) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code);
    if (messagePart) assert.match(e.message, new RegExp(messagePart, 'i'));
    return true;
  });
}

async function clearAll() {
  await db.recursiveDelete(db.collection('matches'));
}

describe('acceptRequest', () => {
  beforeEach(clearAll);
  after(clearAll);

  test('adds the player to the roster and updates counts', async () => {
    await seed({ pending: ['raj'] });
    const result = await acceptRequest(db, {
      matchId: 'm1',
      playerId: 'raj',
      callerUid: 'org',
    });

    assert.deepEqual(result, { group: 'mid', currentPlayers: 1 });
    const m = await matchData();
    assert.equal(m.currentPlayers, 1);
    assert.equal(m.spotsRemaining, 9);
    assert.equal(m.slots.mid.filled, 1);
    assert.equal(m.status, 'filling');
    assert.equal(await requestStatus('raj'), 'accepted');
    assert.equal(await rosterSize(), 1);
  });

  test('taking the last place marks the match full', async () => {
    await seed({ accepted: 9, pending: ['raj'] });
    await acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    const m = await matchData();
    assert.equal(m.currentPlayers, 10);
    assert.equal(m.spotsRemaining, 0);
    assert.equal(m.status, 'full');
  });

  test('an injured player cannot be accepted', async () => {
    await seed({ pending: ['raj'] });
    await db.doc('players/raj').set({ fullName: 'Raj Shrestha', fitness: 'injured' });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
      'failed-precondition',
      'Raj Shrestha is marked injured',
    );
    assert.equal(await requestStatus('raj'), 'pending');

    await db.doc('players/raj').update({ fitness: 'doubtful' });
    await acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    assert.equal(await requestStatus('raj'), 'accepted');
    await db.doc('players/raj').delete();
  });

  test('only the organizer can accept', async () => {
    await seed({ pending: ['raj'] });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'raj' }),
      'permission-denied',
    );
    assert.equal(await requestStatus('raj'), 'pending');
  });

  test('cannot accept twice, or accept into a full match', async () => {
    await seed({ accepted: 9, pending: ['raj', 'amit'] });
    await acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
      'failed-precondition',
      'already accepted',
    );
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'amit', callerUid: 'org' }),
      'failed-precondition',
      'full',
    );
    assert.equal((await matchData()).currentPlayers, 10);
  });

  test('cannot accept after kick-off', async () => {
    await seed({ pending: ['raj'], startAt: new Date(Date.now() - HOUR) });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
      'failed-precondition',
      'started',
    );
  });

  test('preferred position full → falls back to an open slot', async () => {
    await seed({
      maxPlayers: 3,
      pending: ['raj'],
      slots: {
        gk: { needed: 1, filled: 0 },
        def: { needed: 0, filled: 0 },
        mid: { needed: 1, filled: 1 },
        fwd: { needed: 0, filled: 0 },
        any: { needed: 1, filled: 0 },
      },
    });
    const { group } = await acceptRequest(db, {
      matchId: 'm1',
      playerId: 'raj',
      callerUid: 'org',
    });
    assert.equal(group, 'any');
  });

  test('organizer-chosen position must have room', async () => {
    await seed({ pending: ['raj'] });
    await acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org', group: 'gk' });
    await seed({ pending: ['amit'] }); // resets match; gk filled again below
    await db.doc('matches/m1').update({ 'slots.gk.filled': 1 });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'amit', callerUid: 'org', group: 'gk' }),
      'failed-precondition',
      'goalkeeper',
    );
  });

  // ------------------------------------------------------------------
  // The capacity guarantee.
  // ------------------------------------------------------------------

  test('RACE: many players accepted at once for the last place → exactly one gets in', async () => {
    const contenders = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'];
    await seed({ accepted: 9, pending: contenders });

    const results = await Promise.allSettled(
      contenders.map((uid) =>
        acceptRequest(db, { matchId: 'm1', playerId: uid, callerUid: 'org' }),
      ),
    );

    const winners = results.filter((r) => r.status === 'fulfilled');
    assert.equal(winners.length, 1, 'exactly one accept succeeds');
    for (const r of results.filter((r) => r.status === 'rejected')) {
      assert.equal(r.reason.code, 'failed-precondition');
    }

    const m = await matchData();
    assert.equal(m.currentPlayers, 10);
    assert.equal(m.spotsRemaining, 0);
    assert.equal(m.status, 'full');
    assert.equal(await rosterSize(), 10, 'roster never exceeds maxPlayers');

    const statuses = await Promise.all(contenders.map(requestStatus));
    assert.equal(statuses.filter((s) => s === 'accepted').length, 1);
    assert.equal(statuses.filter((s) => s === 'pending').length, 5);
  });

  test('RACE: two organizer devices accept the same player → counted once', async () => {
    await seed({ accepted: 3, pending: ['raj'] });
    const results = await Promise.allSettled([
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
    ]);
    assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
    assert.equal((await matchData()).currentPlayers, 4);
    assert.equal(await rosterSize(), 4);
  });

  test('RACE: filling an empty match concurrently stops exactly at capacity', async () => {
    const pending = Array.from({ length: 8 }, (_, i) => `p${i}`);
    await seed({ maxPlayers: 5, pending, slots: {
      gk: { needed: 0, filled: 0 },
      def: { needed: 0, filled: 0 },
      mid: { needed: 0, filled: 0 },
      fwd: { needed: 0, filled: 0 },
      any: { needed: 5, filled: 0 },
    } });

    const results = await Promise.allSettled(
      pending.map((uid) =>
        acceptRequest(db, { matchId: 'm1', playerId: uid, callerUid: 'org' }),
      ),
    );
    assert.equal(results.filter((r) => r.status === 'fulfilled').length, 5);
    const m = await matchData();
    assert.equal(m.currentPlayers, 5);
    assert.equal(m.slots.any.filled, 5);
    assert.equal(m.status, 'full');
    assert.equal(await rosterSize(), 5);
  });
});

describe('rejectRequest', () => {
  beforeEach(clearAll);

  test('organizer rejects; roster unchanged', async () => {
    await seed({ accepted: 2, pending: ['raj'] });
    await rejectRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    assert.equal(await requestStatus('raj'), 'rejected');
    assert.equal((await matchData()).currentPlayers, 2);
    assert.equal(await rosterSize(), 2);
  });

  test('only organizer, only pending', async () => {
    await seed({ pending: ['raj'] });
    await rejects(
      rejectRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'amit' }),
      'permission-denied',
    );
    await rejectRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    await rejects(
      acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' }),
      'failed-precondition',
    );
  });
});

describe('leaveMatch', () => {
  beforeEach(clearAll);

  test('leaving a full match reopens a place', async () => {
    await seed({ accepted: 9, pending: ['raj'] });
    await acceptRequest(db, { matchId: 'm1', playerId: 'raj', callerUid: 'org' });
    assert.equal((await matchData()).status, 'full');

    await leaveMatch(db, { matchId: 'm1', callerUid: 'raj' });
    const m = await matchData();
    assert.equal(m.currentPlayers, 9);
    assert.equal(m.spotsRemaining, 1);
    assert.equal(m.slots.mid.filled, 0);
    assert.equal(m.status, 'filling');
    assert.equal(await requestStatus('raj'), 'cancelled');
    assert.equal(await rosterSize(), 9);
  });

  test('cannot leave a match you are not in', async () => {
    await seed({ pending: ['raj'] });
    await rejects(
      leaveMatch(db, { matchId: 'm1', callerUid: 'raj' }),
      'failed-precondition',
    );
  });
});

before(clearAll);
