// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import {
  chatPushes,
  lastMessagePreview,
  openDirectChat,
  syncGroupMember,
} from '../../lib/chat/conversations.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'chat-tests');
const db = getFirestore(app);

const conv = async (id) => (await db.doc(`conversations/${id}`).get()).data();

async function clearAll() {
  for (const c of ['matches', 'conversations', 'players']) {
    await db.recursiveDelete(db.collection(c));
  }
}

async function rejects(promise, code) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code);
    return true;
  });
}

describe('group chat membership', () => {
  beforeEach(async () => {
    await clearAll();
    await db.doc('matches/m1').set({
      title: 'Saturday Night Football',
      organizer: { uid: 'org', name: 'Raj', photoUrl: null },
    });
  });
  after(clearAll);

  const joins = (uid) =>
    syncGroupMember(db, 'm1', uid, { player: { name: uid.toUpperCase(), photoUrl: null } });

  test('first roster player creates the chat with the organizer', async () => {
    await joins('amit');
    const c = await conv('match_m1');
    assert.equal(c.type, 'group');
    assert.equal(c.title, 'Saturday Night Football');
    assert.deepEqual(c.participantIds.sort(), ['amit', 'org']);
    assert.equal(c.participants.amit.name, 'AMIT');
  });

  test('joining and leaving keep members equal to organizer + roster', async () => {
    await joins('amit');
    await joins('sita');
    await syncGroupMember(db, 'm1', 'amit', undefined); // left
    const c = await conv('match_m1');
    assert.deepEqual(c.participantIds.sort(), ['org', 'sita']);
    assert.equal(c.participants.amit, undefined);
  });

  test('the organizer is never removed', async () => {
    await joins('amit');
    await syncGroupMember(db, 'm1', 'org', undefined);
    assert.ok((await conv('match_m1')).participantIds.includes('org'));
  });
});

describe('private organizer ↔ player chat', () => {
  beforeEach(async () => {
    await clearAll();
    await db.doc('matches/m1').set({
      title: 'Saturday Night Football',
      organizer: { uid: 'org', name: 'Raj', photoUrl: null },
    });
    await db.doc('matches/m1/requests/amit').set({ status: 'pending' });
    await db.doc('players/amit').set({ fullName: 'Amit Karki', photoUrl: null });
  });

  test('player or organizer can open it; it is created once', async () => {
    const id = await openDirectChat(db, { matchId: 'm1', playerId: 'amit', callerUid: 'amit' });
    assert.equal(id, 'dm_m1_amit');
    const again = await openDirectChat(db, { matchId: 'm1', playerId: 'amit', callerUid: 'org' });
    assert.equal(again, id);
    const c = await conv(id);
    assert.deepEqual(c.participantIds, ['org', 'amit']);
    assert.equal(c.participants.amit.name, 'Amit Karki');
    assert.equal(c.participants.org.name, 'Raj');
  });

  test('outsiders cannot open it', async () => {
    await rejects(
      openDirectChat(db, { matchId: 'm1', playerId: 'amit', callerUid: 'sita' }),
      'permission-denied',
    );
  });

  test('needs a join request first', async () => {
    await rejects(
      openDirectChat(db, { matchId: 'm1', playerId: 'sita', callerUid: 'sita' }),
      'failed-precondition',
    );
  });
});

describe('message pushes (pure)', () => {
  const group = {
    type: 'group',
    title: 'Saturday Night Football',
    participantIds: ['org', 'amit', 'sita'],
    participants: { amit: { name: 'Amit' } },
  };

  test('everyone except the sender; group shows who wrote', () => {
    const out = chatPushes(group, { senderId: 'amit', text: 'Running 5 min late' });
    assert.deepEqual(out.map((p) => p.uid), ['org', 'sita']);
    assert.equal(out[0].title, '💬 Saturday Night Football');
    assert.equal(out[0].body, 'Amit: Running 5 min late');
  });

  test('private chat: title is the sender; photos say so', () => {
    const dm = { ...group, type: 'direct', participantIds: ['org', 'amit'] };
    const [p] = chatPushes(dm, { senderId: 'amit', imageUrl: 'https://x' });
    assert.deepEqual(p, { uid: 'org', title: 'Amit', body: '📷 Photo' });
  });

  test('preview is trimmed', () => {
    const p = lastMessagePreview({ senderId: 'a', text: 'x'.repeat(500), sentAt: 1 });
    assert.equal(p.text.length, 140);
  });
});
