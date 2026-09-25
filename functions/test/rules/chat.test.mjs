import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { createTestEnv, db } from './helpers.mjs';

describe('chat', () => {
  let env;

  before(async () => {
    env = await createTestEnv();
  });
  after(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'conversations/match_m1'), {
        type: 'group',
        matchId: 'm1',
        title: 'Saturday Night Football',
        participantIds: ['org', 'amit'],
        participants: {},
        readAt: {},
        lastMessageAt: new Date(),
      }),
    );
  });

  const msgs = (uid) => collection(db(env, uid), 'conversations/match_m1/messages');

  test('members read the conversation and list their chats', async () => {
    await assertSucceeds(getDoc(doc(db(env, 'amit'), 'conversations/match_m1')));
    const fs = db(env, 'amit');
    await assertSucceeds(
      getDocs(
        query(
          collection(fs, 'conversations'),
          where('participantIds', 'array-contains', 'amit'),
          orderBy('lastMessageAt', 'desc'),
        ),
      ),
    );
  });

  test('outsiders cannot read the conversation or its messages', async () => {
    await assertFails(getDoc(doc(db(env, 'sita'), 'conversations/match_m1')));
    await assertFails(getDocs(msgs('sita')));
  });

  test('members send text or a photo as themselves', async () => {
    await assertSucceeds(
      addDoc(msgs('amit'), { senderId: 'amit', text: 'On my way', sentAt: serverTimestamp() }),
    );
    await assertSucceeds(
      addDoc(msgs('org'), { senderId: 'org', imageUrl: 'https://x/y.jpg', sentAt: serverTimestamp() }),
    );
    await assertSucceeds(getDocs(msgs('amit')));
  });

  test('cannot post as someone else, empty, too long, or as an outsider', async () => {
    await assertFails(
      addDoc(msgs('amit'), { senderId: 'org', text: 'fake', sentAt: serverTimestamp() }),
    );
    await assertFails(addDoc(msgs('amit'), { senderId: 'amit', text: '', sentAt: serverTimestamp() }));
    await assertFails(
      addDoc(msgs('amit'), { senderId: 'amit', text: 'x'.repeat(2001), sentAt: serverTimestamp() }),
    );
    await assertFails(
      addDoc(msgs('sita'), { senderId: 'sita', text: 'hi', sentAt: serverTimestamp() }),
    );
  });

  test('messages cannot be edited', async () => {
    const ref = await addDoc(msgs('amit'), {
      senderId: 'amit',
      text: 'hi',
      sentAt: serverTimestamp(),
    });
    await assertFails(updateDoc(doc(db(env, 'amit'), ref.path), { text: 'edited' }));
  });

  test('members move only their own read marker', async () => {
    const ref = doc(db(env, 'amit'), 'conversations/match_m1');
    await assertSucceeds(updateDoc(ref, { 'readAt.amit': serverTimestamp() }));
    await assertFails(updateDoc(ref, { 'readAt.org': serverTimestamp() }));
    await assertFails(updateDoc(ref, { participantIds: ['amit', 'org', 'sita'] }));
  });

  test('clients cannot create conversations', async () => {
    await assertFails(
      setDoc(doc(db(env, 'amit'), 'conversations/dm_m1_amit'), {
        participantIds: ['amit', 'org'],
      }),
    );
  });
});
