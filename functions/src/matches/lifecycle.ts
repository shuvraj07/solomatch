import { FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';

/**
 * Time-driven match status changes, run by a scheduled function.
 *
 *   published/filling/full ──(startAt passed)──▶ started
 *   started ──(endAt passed)──▶ completed   (+1 gamesPlayed / gamesOrganized)
 *   completed ──(votingClosesAt passed)──▶ Man of the Match decided
 *
 * Every step re-checks the match inside a transaction, so overlapping or
 * repeated runs never apply a change twice.
 */

export const VOTING_WINDOW_MS = 24 * 60 * 60 * 1000;
const BATCH_LIMIT = 200;
const UPCOMING = ['published', 'filling', 'full'];

export interface LifecycleResult {
  started: number;
  completed: number;
  awarded: number;
}

export async function advanceMatches(
  db: Firestore,
  now: Date = new Date(),
): Promise<LifecycleResult> {
  const nowTs = Timestamp.fromDate(now);
  const matches = db.collection('matches');

  const toStart = await matches
    .where('status', 'in', UPCOMING)
    .where('startAt', '<=', nowTs)
    .limit(BATCH_LIMIT)
    .get();
  let started = 0;
  for (const doc of toStart.docs) {
    if (await startMatch(db, doc.id, nowTs)) started++;
  }

  const toComplete = await matches
    .where('status', '==', 'started')
    .where('endAt', '<=', nowTs)
    .limit(BATCH_LIMIT)
    .get();
  let completed = 0;
  for (const doc of toComplete.docs) {
    if (await completeMatch(db, doc.id, nowTs)) completed++;
  }

  const toAward = await matches
    .where('status', '==', 'completed')
    .where('motmClosed', '==', false)
    .where('votingClosesAt', '<=', nowTs)
    .limit(BATCH_LIMIT)
    .get();
  let awarded = 0;
  for (const doc of toAward.docs) {
    if (await closeMotmVoting(db, doc.id, nowTs)) awarded++;
  }

  return { started, completed, awarded };
}

async function startMatch(db: Firestore, matchId: string, now: Timestamp) {
  const ref = db.collection('matches').doc(matchId);
  return db.runTransaction(async (tx) => {
    const m = (await tx.get(ref)).data();
    if (!m || !UPCOMING.includes(m.status) || m.startAt > now) return false;
    tx.update(ref, { status: 'started', updatedAt: FieldValue.serverTimestamp() });
    return true;
  });
}

async function completeMatch(db: Firestore, matchId: string, now: Timestamp) {
  const ref = db.collection('matches').doc(matchId);
  return db.runTransaction(async (tx) => {
    const m = (await tx.get(ref)).data();
    if (!m || m.status !== 'started' || m.endAt > now) return false;
    const roster = await tx.get(ref.collection('roster'));

    tx.update(ref, {
      status: 'completed',
      completedAt: FieldValue.serverTimestamp(),
      votingClosesAt: Timestamp.fromMillis(m.endAt.toMillis() + VOTING_WINDOW_MS),
      motmClosed: false,
      updatedAt: FieldValue.serverTimestamp(),
    });
    for (const entry of roster.docs) {
      tx.set(
        db.collection('players').doc(entry.id),
        { stats: { gamesPlayed: FieldValue.increment(1) } },
        { merge: true },
      );
    }
    tx.set(
      db.collection('players').doc(m.organizer.uid),
      { stats: { gamesOrganized: FieldValue.increment(1) } },
      { merge: true },
    );
    return true;
  });
}

/**
 * Tallies Man of the Match votes. Most votes wins; a tie makes joint
 * winners. No votes means no award.
 */
export async function closeMotmVoting(
  db: Firestore,
  matchId: string,
  now: Timestamp = Timestamp.now(),
) {
  const ref = db.collection('matches').doc(matchId);
  return db.runTransaction(async (tx) => {
    const m = (await tx.get(ref)).data();
    if (!m || m.status !== 'completed' || m.motmClosed !== false) return false;
    if (m.votingClosesAt > now) return false;

    const [votes, roster] = await Promise.all([
      tx.get(ref.collection('motm_votes')),
      tx.get(ref.collection('roster')),
    ]);
    const onRoster = new Map(roster.docs.map((d) => [d.id, d.data()]));

    const tally = new Map<string, number>();
    for (const v of votes.docs) {
      const nominee = v.data().nomineeId as string;
      if (onRoster.has(nominee)) tally.set(nominee, (tally.get(nominee) ?? 0) + 1);
    }
    const top = Math.max(0, ...tally.values());
    const winnerIds = top === 0 ? [] : [...tally].filter(([, n]) => n === top).map(([id]) => id);

    tx.update(ref, {
      motmClosed: true,
      motm: {
        votes: top,
        totalVotes: votes.size,
        winners: winnerIds.map((uid) => {
          const p = onRoster.get(uid)!.player;
          return { uid, name: p.name, username: p.username, photoUrl: p.photoUrl ?? null };
        }),
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
    for (const uid of winnerIds) {
      tx.set(
        db.collection('players').doc(uid),
        { stats: { motmAwards: FieldValue.increment(1) } },
        { merge: true },
      );
    }
    return true;
  });
}
