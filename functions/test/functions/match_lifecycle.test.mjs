// Runs against the Firestore emulator (see `npm run test:functions`).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import { advanceMatches, closeMotmVoting } from '../../lib/matches/lifecycle.js';
import { parseLines, submitMatchReport } from '../../lib/matches/match_report.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'lifecycle-tests');
const db = getFirestore(app);
const HOUR = 60 * 60 * 1000;
const at = (ms) => Timestamp.fromMillis(ms);

const card = (uid) => ({ uid, name: `Player ${uid}`, username: uid, photoUrl: null });

async function seed(id, { status, startAt, endAt, roster = [], extra = {} }) {
  const ref = db.doc(`matches/${id}`);
  const batch = db.batch();
  batch.set(ref, {
    organizer: card('org'),
    status,
    startAt: at(startAt),
    endAt: at(endAt),
    ...extra,
  });
  for (const uid of roster) {
    batch.set(ref.collection('roster').doc(uid), { player: card(uid), group: 'any' });
  }
  await batch.commit();
  return ref;
}

const data = async (path) => (await db.doc(path).get()).data();
const stats = async (uid) => (await data(`players/${uid}`))?.stats ?? {};

async function clearAll() {
  await db.recursiveDelete(db.collection('matches'));
  await db.recursiveDelete(db.collection('players'));
}

async function rejects(promise, code, part) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code);
    if (part) assert.match(e.message, new RegExp(part, 'i'));
    return true;
  });
}

describe('advanceMatches', () => {
  beforeEach(clearAll);
  after(clearAll);

  test('starts matches at kick-off; leaves future and cancelled ones', async () => {
    const now = Date.now();
    await seed('due', { status: 'filling', startAt: now - 1000, endAt: now + HOUR });
    await seed('full', { status: 'full', startAt: now - 1000, endAt: now + HOUR });
    await seed('later', { status: 'published', startAt: now + HOUR, endAt: now + 2 * HOUR });
    await seed('off', { status: 'cancelled', startAt: now - 1000, endAt: now + HOUR });

    const r = await advanceMatches(db, new Date(now));
    assert.equal(r.started, 2);
    assert.equal((await data('matches/due')).status, 'started');
    assert.equal((await data('matches/full')).status, 'started');
    assert.equal((await data('matches/later')).status, 'published');
    assert.equal((await data('matches/off')).status, 'cancelled');
  });

  test('kick-off expires requests still waiting; accepted ones untouched', async () => {
    const now = Date.now();
    const ref = await seed('m1', { status: 'filling', startAt: now - 1000, endAt: now + HOUR });
    await ref.collection('requests').doc('amit').set({ status: 'pending' });
    await ref.collection('requests').doc('sita').set({ status: 'accepted' });

    await advanceMatches(db, new Date(now));
    assert.equal((await data('matches/m1/requests/amit')).status, 'expired');
    assert.equal((await data('matches/m1/requests/sita')).status, 'accepted');
  });

  test('completes matches at the final whistle and counts games', async () => {
    const now = Date.now();
    await seed('m1', {
      status: 'started',
      startAt: now - 2 * HOUR,
      endAt: now - 1000,
      roster: ['raj', 'amit'],
    });

    const r = await advanceMatches(db, new Date(now));
    assert.equal(r.completed, 1);
    const m = await data('matches/m1');
    assert.equal(m.status, 'completed');
    assert.equal(m.motmClosed, false);
    assert.equal(m.votingClosesAt.toMillis(), now - 1000 + 24 * HOUR);
    assert.equal((await stats('raj')).gamesPlayed, 1);
    assert.equal((await stats('amit')).gamesPlayed, 1);
    assert.equal((await stats('org')).gamesOrganized, 1);
  });

  test('a match that has not ended keeps playing', async () => {
    const now = Date.now();
    await seed('m1', { status: 'started', startAt: now - HOUR, endAt: now + HOUR });
    await advanceMatches(db, new Date(now));
    assert.equal((await data('matches/m1')).status, 'started');
  });

  test('running twice never double-counts', async () => {
    const now = Date.now();
    await seed('m1', {
      status: 'started',
      startAt: now - 2 * HOUR,
      endAt: now - 1000,
      roster: ['raj'],
    });
    await Promise.all([
      advanceMatches(db, new Date(now)),
      advanceMatches(db, new Date(now)),
    ]);
    await advanceMatches(db, new Date(now));
    assert.equal((await stats('raj')).gamesPlayed, 1);
    assert.equal((await stats('org')).gamesOrganized, 1);
  });
});

describe('Man of the Match', () => {
  beforeEach(clearAll);

  async function completedMatch({ closesIn = -1000, roster = ['raj', 'amit', 'sita'] } = {}) {
    const now = Date.now();
    return seed('m1', {
      status: 'completed',
      startAt: now - 30 * HOUR,
      endAt: now - 28 * HOUR,
      roster,
      extra: { motmClosed: false, votingClosesAt: at(now + closesIn) },
    });
  }

  async function vote(ref, voter, nominee) {
    await ref.collection('motm_votes').doc(voter).set({ nomineeId: nominee });
  }

  test('most votes wins and gets the award', async () => {
    const ref = await completedMatch();
    await vote(ref, 'raj', 'amit');
    await vote(ref, 'sita', 'amit');
    await vote(ref, 'amit', 'raj');

    const r = await advanceMatches(db);
    assert.equal(r.awarded, 1);
    const m = await data('matches/m1');
    assert.equal(m.motmClosed, true);
    assert.equal(m.motm.votes, 2);
    assert.equal(m.motm.totalVotes, 3);
    assert.deepEqual(m.motm.winners.map((w) => w.uid), ['amit']);
    assert.equal((await stats('amit')).motmAwards, 1);
    assert.equal((await stats('raj')).motmAwards, undefined);
  });

  test('a tie makes joint winners', async () => {
    const ref = await completedMatch();
    await vote(ref, 'raj', 'amit');
    await vote(ref, 'amit', 'raj');
    await advanceMatches(db);
    const m = await data('matches/m1');
    assert.deepEqual(m.motm.winners.map((w) => w.uid).sort(), ['amit', 'raj']);
    assert.equal((await stats('amit')).motmAwards, 1);
    assert.equal((await stats('raj')).motmAwards, 1);
  });

  test('no votes → no award; votes for non-roster players are ignored', async () => {
    const ref = await completedMatch();
    await vote(ref, 'raj', 'stranger');
    await advanceMatches(db);
    const m = await data('matches/m1');
    assert.equal(m.motmClosed, true);
    assert.deepEqual(m.motm.winners, []);
  });

  test('voting stays open until the deadline', async () => {
    const ref = await completedMatch({ closesIn: HOUR });
    await vote(ref, 'raj', 'amit');
    await advanceMatches(db);
    assert.equal((await data('matches/m1')).motmClosed, false);
  });

  test('closing twice awards once', async () => {
    const ref = await completedMatch();
    await vote(ref, 'raj', 'amit');
    await Promise.all([closeMotmVoting(db, 'm1'), closeMotmVoting(db, 'm1')]);
    await advanceMatches(db);
    assert.equal((await stats('amit')).motmAwards, 1);
  });
});

describe('match report', () => {
  beforeEach(clearAll);

  const line = (goals, assists = 0, yellowCards = 0, redCard = false) => ({
    goals,
    assists,
    yellowCards,
    redCard,
  });

  async function reportableMatch(overrides = {}) {
    const now = Date.now();
    return seed('m1', {
      status: 'completed',
      startAt: now - 3 * HOUR,
      endAt: now - HOUR,
      roster: ['raj', 'amit'],
      extra: { motmClosed: false, votingClosesAt: at(now + 23 * HOUR) },
      ...overrides,
    });
  }

  const save = (lines, callerUid = 'org') =>
    submitMatchReport(db, { matchId: 'm1', callerUid, lines });

  test('adds goals, assists and cards to career totals', async () => {
    await reportableMatch();
    await save({ raj: line(2, 1, 1), amit: line(0, 2, 0, true) });

    const m = await data('matches/m1');
    assert.deepEqual(m.report.players.raj, line(2, 1, 1));
    assert.deepEqual(await stats('raj'), { goals: 2, assists: 1, yellowCards: 1 });
    assert.deepEqual(await stats('amit'), { assists: 2, redCards: 1 });
  });

  test('editing the report adjusts totals instead of double-counting', async () => {
    await reportableMatch();
    await save({ raj: line(2, 0, 1), amit: line(1) });
    await save({ raj: line(3, 0, 0), amit: line(0) });

    assert.deepEqual(await stats('raj'), { goals: 3, yellowCards: 0 });
    assert.equal((await stats('amit')).goals, 0);
    assert.deepEqual((await data('matches/m1')).report.players.raj, line(3));
  });

  test('only the organizer, only after the match, only roster players', async () => {
    const now = Date.now();
    await reportableMatch();
    await rejects(save({ raj: line(1) }, 'raj'), 'permission-denied');
    await rejects(save({ stranger: line(1) }), 'invalid-argument', 'roster');

    await seed('m1', { status: 'started', startAt: now - HOUR, endAt: now + HOUR, roster: ['raj'] });
    await rejects(save({ raj: line(1) }), 'failed-precondition', 'after the match');
  });

  test('locked once voting closes', async () => {
    await reportableMatch({ extra: { motmClosed: true, votingClosesAt: at(Date.now() - 1000) } });
    await rejects(save({ raj: line(1) }), 'failed-precondition', 'no longer');
  });

  test('rejects impossible numbers', () => {
    assert.throws(() => parseLines({ raj: line(-1) }), /goals/);
    assert.throws(() => parseLines({ raj: line(0, 0, 3) }), /yellowCards/);
    assert.throws(() => parseLines({ raj: { ...line(1), redCard: 'yes' } }), /red card/);
    assert.throws(() => parseLines([line(1)]), /Missing/);
    assert.deepEqual(parseLines({ raj: line(1, 2, 2, true) }), { raj: line(1, 2, 2, true) });
  });
});
