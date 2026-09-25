// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import { deleteAccount } from '../../lib/account/delete_account.js';
import { openDirectChat } from '../../lib/chat/conversations.js';
import { categoryOf, pushToUser } from '../../lib/notifications/deliver.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'account-tests');
const db = getFirestore(app);
const HOUR = 60 * 60 * 1000;
const card = (uid) => ({ uid, name: uid, username: uid, photoUrl: null });

async function clearAll() {
  for (const c of ['matches', 'players', 'usernames', 'users', 'conversations', 'reviews', 'match_drafts']) {
    await db.recursiveDelete(db.collection(c));
  }
}

const exists = async (p) => (await db.doc(p).get()).exists;
const data = async (p) => (await db.doc(p).get()).data();

describe('deleteAccount', () => {
  let deletedAuth;
  let deletedPrefixes;
  const deps = () => ({
    db,
    deleteAuthUser: async (uid) => deletedAuth.push(uid),
    deleteFiles: async (prefix) => deletedPrefixes.push(prefix),
  });

  beforeEach(async () => {
    await clearAll();
    deletedAuth = [];
    deletedPrefixes = [];
    const future = Timestamp.fromMillis(Date.now() + 24 * HOUR);
    const past = Timestamp.fromMillis(Date.now() - 24 * HOUR);
    const b = db.batch();
    b.set(db.doc('players/amit'), { fullName: 'Amit', username: 'amit' });
    b.set(db.doc('usernames/amit'), { uid: 'amit' });
    b.set(db.doc('users/amit'), { email: 'a@x.com' });
    b.set(db.doc('users/amit/devices/tok'), {});
    b.set(db.doc('users/amit/notifications/n1'), { read: false });
    // Upcoming match Amit plays in (accepted) → he leaves, place reopens.
    b.set(db.doc('matches/playing'), {
      organizer: card('raj'), title: 'Playing', status: 'full', startAt: future,
      maxPlayers: 2, currentPlayers: 2, spotsRemaining: 0,
      slots: { gk: { needed: 0, filled: 0 }, def: { needed: 0, filled: 0 }, mid: { needed: 0, filled: 0 }, fwd: { needed: 0, filled: 0 }, any: { needed: 2, filled: 2 } },
    });
    b.set(db.doc('matches/playing/roster/amit'), { player: card('amit'), group: 'any' });
    b.set(db.doc('matches/playing/requests/amit'), { status: 'accepted', player: card('amit') });
    // Upcoming match with a pending request → withdrawn.
    b.set(db.doc('matches/waiting'), { organizer: card('raj'), title: 'Waiting', status: 'published', startAt: future });
    b.set(db.doc('matches/waiting/requests/amit'), { status: 'pending', player: card('amit') });
    // Past match: history kept.
    b.set(db.doc('matches/old'), { organizer: card('raj'), title: 'Old', status: 'completed', startAt: past });
    b.set(db.doc('matches/old/requests/amit'), { status: 'accepted', player: card('amit') });
    // Match Amit organizes → cancelled.
    b.set(db.doc('matches/mine'), { organizer: card('amit'), title: 'Mine', status: 'filling', startAt: future });
    b.set(db.doc('conversations/match_playing'), { participantIds: ['raj', 'amit'], participants: { amit: { name: 'Amit' } } });
    b.set(db.doc('reviews/old_amit_raj'), { reviewerId: 'amit', reviewer: { name: 'Amit', photoUrl: null } });
    await b.commit();
  });
  after(clearAll);

  test('leaves, cancels, withdraws, anonymizes and deletes personal data', async () => {
    const summary = await deleteAccount(deps(), 'amit');
    assert.deepEqual(summary, { leftMatches: 1, cancelledMatches: 1 });

    const playing = await data('matches/playing');
    assert.equal(playing.currentPlayers, 1);
    assert.equal(playing.status, 'filling');
    assert.equal(await exists('matches/playing/roster/amit'), false);
    assert.equal((await data('matches/waiting/requests/amit')).status, 'cancelled');
    assert.equal((await data('matches/old/requests/amit')).status, 'accepted');
    assert.equal((await data('matches/mine')).status, 'cancelled');

    const conv = await data('conversations/match_playing');
    assert.deepEqual(conv.participantIds, ['raj']);
    assert.equal(conv.participants.amit.name, 'Deleted player');
    assert.equal((await data('reviews/old_amit_raj')).reviewer.name, 'Deleted player');

    for (const p of ['players/amit', 'usernames/amit', 'users/amit', 'users/amit/devices/tok', 'users/amit/notifications/n1']) {
      assert.equal(await exists(p), false, p);
    }
    assert.deepEqual(deletedAuth, ['amit']);
    assert.ok(deletedPrefixes.includes('users/amit/'));
  });

  test('running it again is harmless', async () => {
    await deleteAccount(deps(), 'amit');
    await deleteAccount(deps(), 'amit');
    assert.equal((await data('matches/playing')).currentPlayers, 1);
  });
});

describe('notification preferences', () => {
  beforeEach(clearAll);

  class FakePush {
    constructor() {
      this.sent = [];
    }
    async sendEachForMulticast(m) {
      this.sent.push(m);
      return { responses: m.tokens.map(() => ({ success: true })) };
    }
  }

  test('types map to the settings toggles', () => {
    assert.equal(categoryOf('new_request'), 'requests');
    assert.equal(categoryOf('chat_message'), 'chat');
    assert.equal(categoryOf('motm_won'), 'reviews');
    assert.equal(categoryOf('match_reminder'), 'matches');
  });

  test('a muted category is not pushed; others still are', async () => {
    await db.doc('users/amit').set({ notificationPrefs: { chat: false } });
    await db.doc('users/amit/devices/tok').set({});
    const push = new FakePush();
    const note = { title: 't', body: 'b' };
    assert.equal(await pushToUser(db, push, 'amit', note, { type: 'chat_message' }), false);
    assert.equal(await pushToUser(db, push, 'amit', note, { type: 'match_reminder' }), true);
    assert.equal(push.sent.length, 1);
  });
});

describe('blocking and private chat', () => {
  beforeEach(async () => {
    await clearAll();
    await db.doc('matches/m1').set({ title: 'M', organizer: { uid: 'raj', name: 'Raj' } });
    await db.doc('matches/m1/requests/amit').set({ status: 'pending' });
  });

  test('either side blocking stops a private chat', async () => {
    await db.doc('users/raj/blocks/amit').set({});
    await assert.rejects(
      openDirectChat(db, { matchId: 'm1', playerId: 'amit', callerUid: 'amit' }),
      (e) => e.code === 'permission-denied',
    );
    await db.recursiveDelete(db.collection('users'));
    await db.doc('users/amit/blocks/raj').set({});
    await assert.rejects(
      openDirectChat(db, { matchId: 'm1', playerId: 'amit', callerUid: 'raj' }),
      (e) => e.code === 'permission-denied',
    );
  });
});
