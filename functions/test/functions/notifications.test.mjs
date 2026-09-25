// Pure rules + delivery against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import { deliver } from '../../lib/notifications/deliver.js';
import {
  dueReminder,
  forMatchChange,
  forRequestChange,
} from '../../lib/notifications/messages.js';
import { sendReminders } from '../../lib/notifications/reminders.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'notification-tests');
const db = getFirestore(app);
const MIN = 60 * 1000;
const HOUR = 60 * MIN;

const match = (over = {}) => ({
  title: 'Saturday Night Football',
  organizer: { uid: 'org' },
  status: 'filling',
  maxPlayers: 10,
  spotsRemaining: 4,
  startAt: Timestamp.fromMillis(Date.now() + 48 * HOUR),
  venue: { name: 'Dhuku Futsal' },
  ...over,
});
const req = (status, over = {}) => ({
  status,
  player: { uid: 'amit', name: 'Amit Karki' },
  preferredGroup: 'gk',
  ...over,
});
const summary = (items) => items.map((n) => `${n.uid}:${n.type}`);

/** Records pushes; tokens listed in [dead] fail as unregistered. */
class FakePush {
  constructor(dead = []) {
    this.sent = [];
    this.dead = new Set(dead);
  }
  async sendEachForMulticast(msg) {
    this.sent.push(msg);
    return {
      responses: msg.tokens.map((t) =>
        this.dead.has(t)
          ? { success: false, error: { code: 'messaging/registration-token-not-registered' } }
          : { success: true },
      ),
    };
  }
}

describe('who gets notified: join requests', () => {
  test('new request → organizer, with the wanted position', () => {
    const out = forRequestChange('m1', 'amit', undefined, req('pending'), match());
    assert.deepEqual(summary(out), ['org:new_request']);
    assert.match(out[0].body, /Amit Karki wants to play goalkeeper in Saturday Night Football/);
  });

  test('asking again after withdrawing → organizer again', () => {
    const out = forRequestChange('m1', 'amit', req('cancelled'), req('pending'), match());
    assert.deepEqual(summary(out), ['org:new_request']);
  });

  test('accepted / rejected → the player', () => {
    const acc = forRequestChange('m1', 'amit', req('pending'), req('accepted'), match());
    assert.deepEqual(summary(acc), ['amit:request_accepted']);
    assert.equal(acc[0].title, "You're in! ⚽");
    assert.equal(acc[0].body, 'Your request to join Saturday Night Football was accepted.');
    const rej = forRequestChange('m1', 'amit', req('pending'), req('rejected'), match());
    assert.deepEqual(summary(rej), ['amit:request_rejected']);
  });

  test('accepted player leaves → organizer; withdrawing a pending request → nobody', () => {
    assert.deepEqual(
      summary(forRequestChange('m1', 'amit', req('accepted'), req('cancelled'), match())),
      ['org:player_left'],
    );
    assert.deepEqual(forRequestChange('m1', 'amit', req('pending'), req('cancelled'), match()), []);
  });
});

describe('who gets notified: match changes', () => {
  const audience = { roster: ['raj', 'amit'], pending: ['sita', 'amit'] };

  test('full → organizer', () => {
    const out = forMatchChange('m1', match(), match({ status: 'full', spotsRemaining: 0 }), audience);
    assert.deepEqual(summary(out), ['org:match_full']);
  });

  test('cancelled → roster and pending requesters, once each', () => {
    const out = forMatchChange('m1', match(), match({ status: 'cancelled' }), audience);
    assert.deepEqual(summary(out).sort(), ['amit:match_cancelled', 'raj:match_cancelled', 'sita:match_cancelled']);
  });

  test('almost full only when crossing to 2 spots left', () => {
    assert.deepEqual(
      summary(forMatchChange('m1', match({ spotsRemaining: 3 }), match({ spotsRemaining: 2 }), audience)),
      ['org:match_almost_full'],
    );
    assert.deepEqual(
      forMatchChange('m1', match({ spotsRemaining: 2 }), match({ spotsRemaining: 2, title: 'Renamed' }), audience),
      [],
    );
  });

  test('completed → roster asked to vote; MOTM decided → winners', () => {
    assert.deepEqual(
      summary(forMatchChange('m1', match({ status: 'started' }), match({ status: 'completed' }), audience)),
      ['raj:motm_vote', 'amit:motm_vote'],
    );
    const decided = match({ status: 'completed', motm: { winners: [{ uid: 'amit' }] } });
    assert.deepEqual(
      summary(forMatchChange('m1', match({ status: 'completed' }), decided, audience)),
      ['amit:motm_won'],
    );
  });
});

describe('reminder timing', () => {
  const start = Date.UTC(2026, 8, 28, 12);

  test('sends the tightest due window and marks wider ones sent', () => {
    assert.equal(dueReminder(start, start - 25 * HOUR), null);
    assert.equal(dueReminder(start, start - 23 * HOUR).send.key, 'h24');
    const late = dueReminder(start, start - 90 * MIN);
    assert.equal(late.send.key, 'h2');
    assert.deepEqual(late.markSent, ['h24', 'h2']);
    assert.equal(dueReminder(start, start - 20 * MIN).send.key, 'm30');
  });

  test('never repeats or fires after kick-off', () => {
    assert.equal(dueReminder(start, start - 20 * MIN, { h24: true, h2: true, m30: true }), null);
    assert.equal(dueReminder(start, start + MIN), null);
  });
});

describe('delivery (emulator)', () => {
  const clear = async () => {
    await db.recursiveDelete(db.collection('users'));
    await db.recursiveDelete(db.collection('matches'));
  };
  beforeEach(clear);
  after(clear);

  const note = (uid) => ({
    uid,
    type: 'request_accepted',
    title: "You're in! ⚽",
    body: 'Your request to join X was accepted.',
    matchId: 'm1',
  });

  test('writes the inbox, pushes to every device and drops dead tokens', async () => {
    await db.doc('users/amit/devices/tokA').set({ platform: 'android' });
    await db.doc('users/amit/devices/tokDead').set({ platform: 'android' });
    const push = new FakePush(['tokDead']);

    await deliver(db, push, [note('amit')], 'evt1');

    const inbox = await db.collection('users/amit/notifications').get();
    assert.equal(inbox.size, 1);
    assert.equal(inbox.docs[0].data().read, false);
    assert.equal(push.sent.length, 1);
    assert.deepEqual(push.sent[0].tokens.sort(), ['tokA', 'tokDead']);
    assert.equal(push.sent[0].data.route, '/matches/m1');
    assert.equal((await db.doc('users/amit/devices/tokDead').get()).exists, false);
    assert.equal((await db.doc('users/amit/devices/tokA').get()).exists, true);
  });

  test('a retried event does not notify twice', async () => {
    await db.doc('users/amit/devices/tokA').set({ platform: 'android' });
    const push = new FakePush();
    await deliver(db, push, [note('amit')], 'evt1');
    await deliver(db, push, [note('amit')], 'evt1');
    assert.equal(push.sent.length, 1);
    assert.equal((await db.collection('users/amit/notifications').get()).size, 1);
  });

  test('no devices → inbox only', async () => {
    const push = new FakePush();
    await deliver(db, push, [note('amit')], 'evt2');
    assert.equal(push.sent.length, 0);
    assert.equal((await db.collection('users/amit/notifications').get()).size, 1);
  });

  test('reminders go to organizer + roster once per window', async () => {
    const now = new Date();
    const ref = db.doc('matches/m1');
    await ref.set(match({ startAt: Timestamp.fromMillis(now.getTime() + 25 * MIN) }));
    await ref.collection('roster').doc('amit').set({ group: 'any' });
    await db.doc('users/org/devices/tOrg').set({});
    await db.doc('users/amit/devices/tAmit').set({});
    const push = new FakePush();

    await sendReminders(db, push, now);
    await sendReminders(db, push, now); // next run: nothing new

    assert.equal(push.sent.length, 2);
    assert.equal(push.sent[0].notification.title, 'Your football match starts in 30 minutes ⚽');
    const m = (await ref.get()).data();
    assert.deepEqual(m.remindersSent, { h24: true, h2: true, m30: true });
  });

  test('no reminders for cancelled or far-off matches', async () => {
    const now = new Date();
    await db.doc('matches/c').set(match({ status: 'cancelled', startAt: Timestamp.fromMillis(now.getTime() + 20 * MIN) }));
    await db.doc('matches/far').set(match({ startAt: Timestamp.fromMillis(now.getTime() + 3 * 24 * HOUR) }));
    const push = new FakePush();
    assert.equal(await sendReminders(db, push, now), 0);
  });
});
