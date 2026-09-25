import { FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';

import { RuleError } from '../shared/rule_error.js';

/** One player's contribution in a match, as entered by the organizer. */
export interface PlayerLine {
  goals: number;
  assists: number;
  yellowCards: number;
  redCard: boolean;
}

const LIMITS = { goals: 30, assists: 30, yellowCards: 2 };
const EMPTY: PlayerLine = { goals: 0, assists: 0, yellowCards: 0, redCard: false };

/** Validates untrusted input from the app. */
export function parseLines(raw: unknown): Record<string, PlayerLine> {
  if (typeof raw !== 'object' || raw === null || Array.isArray(raw)) {
    throw new RuleError('invalid-argument', 'Missing player stats.');
  }
  const out: Record<string, PlayerLine> = {};
  for (const [uid, value] of Object.entries(raw as Record<string, unknown>)) {
    const v = value as Record<string, unknown> | null;
    const int = (key: 'goals' | 'assists' | 'yellowCards') => {
      const n = v?.[key];
      if (!Number.isInteger(n) || (n as number) < 0 || (n as number) > LIMITS[key]) {
        throw new RuleError('invalid-argument', `Invalid ${key} for a player.`);
      }
      return n as number;
    };
    if (typeof v?.redCard !== 'boolean') {
      throw new RuleError('invalid-argument', 'Invalid red card value.');
    }
    out[uid] = {
      goals: int('goals'),
      assists: int('assists'),
      yellowCards: int('yellowCards'),
      redCard: v.redCard,
    };
  }
  return out;
}

export interface ReportInput {
  matchId: string;
  callerUid: string;
  lines: Record<string, PlayerLine>;
}

/**
 * Saves the organizer's match report and updates each player's career
 * totals by the *difference* from any earlier version, so editing a report
 * never double-counts. Allowed after the match ends, until MOTM voting
 * closes.
 */
export async function submitMatchReport(db: Firestore, input: ReportInput) {
  const ref = db.collection('matches').doc(input.matchId);

  await db.runTransaction(async (tx) => {
    const m = (await tx.get(ref)).data();
    if (!m) throw new RuleError('not-found', 'Match not found.');
    if (m.organizer?.uid !== input.callerUid) {
      throw new RuleError('permission-denied', 'Only the organizer can report this match.');
    }
    if (m.status !== 'completed') {
      throw new RuleError('failed-precondition', 'You can add the report after the match ends.');
    }
    if (m.votingClosesAt.toMillis() <= Date.now()) {
      throw new RuleError('failed-precondition', 'The report can no longer be changed.');
    }

    const roster = await tx.get(ref.collection('roster'));
    const onRoster = new Set(roster.docs.map((d) => d.id));
    for (const uid of Object.keys(input.lines)) {
      if (!onRoster.has(uid)) {
        throw new RuleError('invalid-argument', 'Report includes someone who was not on the roster.');
      }
    }

    const previous: Record<string, PlayerLine> = m.report?.players ?? {};
    for (const uid of new Set([...Object.keys(previous), ...Object.keys(input.lines)])) {
      const before = { ...EMPTY, ...previous[uid] };
      const after = { ...EMPTY, ...input.lines[uid] };
      const delta = {
        goals: after.goals - before.goals,
        assists: after.assists - before.assists,
        yellowCards: after.yellowCards - before.yellowCards,
        redCards: Number(after.redCard) - Number(before.redCard),
      };
      if (Object.values(delta).every((d) => d === 0)) continue;
      tx.set(
        db.collection('players').doc(uid),
        {
          stats: Object.fromEntries(
            Object.entries(delta)
              .filter(([, d]) => d !== 0)
              .map(([k, d]) => [k, FieldValue.increment(d)]),
          ),
        },
        { merge: true },
      );
    }

    tx.update(ref, {
      report: {
        players: input.lines,
        submittedAt: m.report?.submittedAt ?? Timestamp.now(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
