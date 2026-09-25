// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import {
  claimFullTime,
  fullTimeMessage,
  reachedFullTime,
  goalMessage,
  liveAudience,
  recomputeScore,
  scoreFrom,
} from '../../lib/live/live.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'live-tests');
const db = getFirestore(app);

const match = {
  title: 'Friday Futsal',
  organizer: { uid: 'raj' },
  teams: { home: 'Tigers', away: 'Eagles' },
};

async function clearAll() {
  await db.recursiveDelete(db.collection('matches'));
}

describe('live match center', () => {
  beforeEach(clearAll);
  after(clearAll);

  test('score counts goals per team; cards do not count', () => {
    assert.deepEqual(
      scoreFrom([
        { type: 'goal', team: 'home' },
        { type: 'goal', team: 'away' },
        { type: 'goal', team: 'home' },
        { type: 'yellow', team: 'home' },
        { type: 'goal', team: 'nobody' },
      ]),
      { home: 2, away: 1 },
    );
    assert.deepEqual(scoreFrom([]), { home: 0, away: 0 });
  });

  test('recompute writes the score and follows undo', async () => {
    const ref = db.doc('matches/m1');
    await ref.set(match);
    await ref.collection('events').doc('e1').set({ type: 'goal', team: 'home' });
    await ref.collection('events').doc('e2').set({ type: 'goal', team: 'away' });
    assert.deepEqual(await recomputeScore(db, 'm1'), { home: 1, away: 1 });
    assert.deepEqual((await ref.get()).data().score, { home: 1, away: 1 });

    await ref.collection('events').doc('e2').delete(); // undo
    await recomputeScore(db, 'm1');
    assert.deepEqual((await ref.get()).data().score, { home: 1, away: 0 });
  });

  test('audience: organizer, roster and followers, once each', async () => {
    const ref = db.doc('matches/m1');
    await ref.set(match);
    await ref.collection('roster').doc('amit').set({});
    await ref.collection('roster').doc('sita').set({});
    await ref.collection('followers').doc('fan').set({});
    await ref.collection('followers').doc('sita').set({});
    const audience = await liveAudience(db, 'm1', match);
    assert.deepEqual(audience.sort(), ['amit', 'fan', 'raj', 'sita']);
  });

  test('messages use team names (defaults Team A / Team B)', () => {
    const goal = goalMessage(
      match,
      { team: 'away', playerName: 'Sita Rai', minute: 23 },
      { home: 1, away: 2 },
    );
    assert.equal(goal.title, '⚽ GOAL! Tigers 1 – 2 Eagles');
    assert.equal(goal.body, "Sita Rai (Eagles) scores 23' · Friday Futsal");

    const noNames = { ...match, teams: undefined };
    assert.equal(
      fullTimeMessage(noNames, { home: 3, away: 0 }).title,
      '🏁 Full time: Team A 3 – 0 Team B',
    );
  });

  test('full time: organizer whistle or completion, notified once', async () => {
    const running = { clock: { phase: 'second_half' }, status: 'started' };
    assert.equal(reachedFullTime(running, { ...running, clock: { phase: 'full_time' } }), true);
    // Scheduler completes a match that had live goals but no whistle.
    assert.equal(
      reachedFullTime({ status: 'started' }, { status: 'completed', score: { home: 1, away: 0 } }),
      true,
    );
    // Nothing was followed live: no full-time push.
    assert.equal(reachedFullTime({ status: 'started' }, { status: 'completed' }), false);

    await db.doc('matches/m1').set(match);
    assert.equal(await claimFullTime(db, 'm1'), true);
    assert.equal(await claimFullTime(db, 'm1'), false);
  });
});
