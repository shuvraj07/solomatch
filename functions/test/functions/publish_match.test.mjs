// Runs against the Firestore emulator (npm run test:functions).
import assert from 'node:assert/strict';
import { after, beforeEach, describe, test } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

import { publishMatch } from '../../lib/matches/publish_match.js';

const app = initializeApp({ projectId: 'demo-solomatch' }, 'publish-tests');
const db = getFirestore(app);
const HOUR = 60 * 60 * 1000;

const profile = (name, position = 'centralMidfielder', stats) => ({
  fullName: name,
  username: name.toLowerCase().split(' ')[0],
  photoUrl: null,
  primaryPosition: position,
  secondaryPositions: [],
  skillLevel: 'intermediate',
  ...(stats ? { stats } : {}),
});

function draft(over = {}) {
  const start = Date.now() + 24 * HOUR;
  return {
    organizerId: 'raj',
    title: '  Saturday Night Football ',
    venue: { name: 'Dhuku Futsal', address: 'Baneshwor', city: 'Kathmandu', placeId: null, lat: null, lng: null },
    startAt: Timestamp.fromMillis(start),
    endAt: Timestamp.fromMillis(start + 2 * HOUR),
    format: 'fiveASide',
    maxPlayers: 10,
    neededPositions: { gk: 1, def: 2 },
    skillLevel: 'any',
    priceAmount: 0,
    isIndoor: false,
    description: '',
    rules: '',
    photos: [],
    ...over,
  };
}

async function seed(d) {
  await db.doc('match_drafts/d1').set(d);
}

const publish = (callerUid = 'raj') => publishMatch(db, { draftId: 'd1', callerUid });
const data = async (p) => (await db.doc(p).get()).data();
const count = async (p) => (await db.collection(p).count().get()).data().count;

async function rejects(promise, code, part) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.code, code);
    if (part) assert.match(e.message, new RegExp(part, 'i'));
    return true;
  });
}

async function clearAll() {
  for (const c of ['matches', 'match_drafts', 'players']) {
    await db.recursiveDelete(db.collection(c));
  }
}

describe('publishMatch', () => {
  beforeEach(async () => {
    await clearAll();
    const batch = db.batch();
    batch.set(db.doc('players/raj'), profile('Raj Shrestha', 'striker'));
    batch.set(db.doc('players/amit'), profile('Amit Karki', 'goalkeeper', { gamesPlayed: 12, ratingAvg: 4.5, ratingCount: 4 }));
    batch.set(db.doc('players/sita'), profile('Sita Rai', 'centerBack'));
    batch.set(db.doc('players/hari'), profile('Hari KC', 'centralMidfielder'));
    await batch.commit();
  });
  after(clearAll);

  test('injured players cannot be put in the lineup', async () => {
    await db.doc('players/amit').update({ fitness: 'injured' });
    await seed(draft({ lineup: [{ uid: 'amit', group: 'gk' }] }));
    await rejects(publish(), 'invalid-argument', 'Amit Karki is marked injured');

    await db.doc('players/raj').update({ fitness: 'injured' });
    await seed(draft({ organizerPlaying: true }));
    await rejects(publish(), 'invalid-argument', "You're marked injured");
  });

  test('plain publish: open match, no roster, draft removed', async () => {
    await seed(draft());
    const r = await publish();
    assert.equal(r.currentPlayers, 0);
    const m = await data('matches/d1');
    assert.equal(m.title, 'Saturday Night Football');
    assert.equal(m.status, 'published');
    assert.equal(m.spotsRemaining, 10);
    assert.deepEqual(m.slots.any, { needed: 7, filled: 0 });
    assert.equal(m.organizer.name, 'Raj Shrestha');
    assert.equal((await db.doc('match_drafts/d1').get()).exists, false);
  });

  test('organizer + friends + guests: only the remaining spots are open', async () => {
    await seed(
      draft({
        organizerPlaying: true,
        organizerGroup: 'fwd',
        lineup: [{ uid: 'amit', group: 'gk' }, { uid: 'sita' }, { uid: 'hari' }],
        guestCount: 3,
      }),
    );
    const r = await publish();

    assert.equal(r.currentPlayers, 7);
    assert.deepEqual(r.addedPlayers.sort(), ['amit', 'hari', 'sita']);
    const m = await data('matches/d1');
    assert.equal(m.currentPlayers, 7);
    assert.equal(m.spotsRemaining, 3);
    assert.equal(m.status, 'filling');
    assert.equal(m.guestCount, 3);
    assert.deepEqual(m.slots.gk, { needed: 1, filled: 1 });
    assert.equal(m.slots.def.filled, 1); // Sita (CB)
    // Raj (FWD) + Hari (MID) have no specific slots → ANY; plus 3 guests.
    assert.equal(m.slots.any.filled, 5);
    assert.equal(await count('matches/d1/roster'), 4);

    // Friends show up as accepted (My Matches, Leave button) with a real card.
    const amit = await data('matches/d1/requests/amit');
    assert.equal(amit.status, 'accepted');
    assert.equal(amit.player.gamesPlayed, 12);
    assert.equal(amit.player.ratingAvg, 4.5);
    assert.equal(amit.match.venueName, 'Dhuku Futsal');
  });

  test('a fully pre-filled match is published as full', async () => {
    await seed(draft({ maxPlayers: 4, neededPositions: {}, lineup: [{ uid: 'amit' }, { uid: 'sita' }], guestCount: 2 }));
    await publish();
    assert.equal((await data('matches/d1')).status, 'full');
  });

  test('cannot confirm more players than places', async () => {
    await seed(draft({ maxPlayers: 3, neededPositions: {}, lineup: [{ uid: 'amit' }, { uid: 'sita' }], guestCount: 2 }));
    await rejects(publish(), 'failed-precondition', 'full');
    assert.equal((await db.doc('matches/d1').get()).exists, false);
  });

  test('rejects duplicates, unknown players and adding yourself as a friend', async () => {
    await seed(draft({ lineup: [{ uid: 'amit' }, { uid: 'amit' }] }));
    await rejects(publish(), 'invalid-argument', 'twice');
    await seed(draft({ lineup: [{ uid: 'ghost' }] }));
    await rejects(publish(), 'invalid-argument', 'no longer exists');
    await seed(draft({ lineup: [{ uid: 'raj' }] }));
    await rejects(publish(), 'invalid-argument', "playing too");
  });

  test('only the organizer can publish their draft', async () => {
    await seed(draft());
    await rejects(publish('amit'), 'permission-denied');
  });

  test('validates the draft on the server', async () => {
    const past = Date.now() - HOUR;
    for (const [over, part] of [
      [{ title: 'ab' }, 'Title'],
      [{ venue: null }, 'venue'],
      [{ startAt: Timestamp.fromMillis(past), endAt: Timestamp.fromMillis(past + HOUR) }, 'future'],
      [{ maxPlayers: 40 }, 'Players'],
      [{ neededPositions: { gk: 8, def: 8 } }, 'Positions add up'],
      [{ priceAmount: -1 }, 'Price'],
    ]) {
      await seed(draft(over));
      await rejects(publish(), 'invalid-argument', part);
    }
  });

  test('cannot publish the same draft twice', async () => {
    await seed(draft());
    await publish();
    await seed(draft());
    await rejects(publish(), 'failed-precondition', 'already published');
  });
});
