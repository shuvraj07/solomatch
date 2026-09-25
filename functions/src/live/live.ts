import { FieldValue, type DocumentData, type Firestore } from 'firebase-admin/firestore';

/**
 * Live match center. The organizer posts events (goals, cards) to
 * `matches/{id}/events`; anyone signed in can watch. The server keeps
 * `matches/{id}.score` in sync so lists (Home "Live now") show the score,
 * and pushes goals to players and followers.
 */

export type Side = 'home' | 'away';
export interface Score {
  home: number;
  away: number;
}

const DEFAULT_TEAMS = { home: 'Team A', away: 'Team B' };

export function teamNames(match: DocumentData): { home: string; away: string } {
  return { ...DEFAULT_TEAMS, ...(match.teams ?? {}) };
}

/** Score from the event list: each goal counts for its `team`. */
export function scoreFrom(events: DocumentData[]): Score {
  const score = { home: 0, away: 0 };
  for (const e of events) {
    if (e.type === 'goal' && (e.team === 'home' || e.team === 'away')) score[e.team as Side]++;
  }
  return score;
}

/** Recounts goals and writes `score` on the match. Idempotent. */
export async function recomputeScore(db: Firestore, matchId: string): Promise<Score> {
  const ref = db.collection('matches').doc(matchId);
  const events = await ref.collection('events').get();
  const score = scoreFrom(events.docs.map((d) => d.data()));
  await ref.update({ score, scoreUpdatedAt: FieldValue.serverTimestamp() });
  return score;
}

/** "Team A 2 – 1 Team B". */
export function scoreLine(match: DocumentData, score: Score): string {
  const t = teamNames(match);
  return `${t.home} ${score.home} – ${score.away} ${t.away}`;
}

export function goalMessage(match: DocumentData, event: DocumentData, score: Score) {
  const team = teamNames(match)[event.team as Side] ?? '';
  const scorer = event.playerName ? `${event.playerName} (${team})` : team;
  return {
    title: `⚽ GOAL! ${scoreLine(match, score)}`,
    body: `${scorer} scores ${event.minute}' · ${match.title}`,
  };
}

export function fullTimeMessage(match: DocumentData, score: Score) {
  return {
    title: `🏁 Full time: ${scoreLine(match, score)}`,
    body: match.title,
  };
}

/** Everyone who cares about a live match: organizer, roster, followers. */
export async function liveAudience(db: Firestore, matchId: string, match: DocumentData) {
  const ref = db.collection('matches').doc(matchId);
  const [roster, followers] = await Promise.all([
    ref.collection('roster').get(),
    ref.collection('followers').get(),
  ]);
  return [
    ...new Set([
      match.organizer?.uid as string,
      ...roster.docs.map((d) => d.id),
      ...followers.docs.map((d) => d.id),
    ]),
  ].filter(Boolean);
}

/**
 * True once per match: when the organizer blows full time or the match
 * completes, whichever comes first. Claims a flag in a transaction so the
 * full-time push is sent only once.
 */
export async function claimFullTime(db: Firestore, matchId: string): Promise<boolean> {
  const ref = db.collection('matches').doc(matchId);
  return db.runTransaction(async (tx) => {
    const m = (await tx.get(ref)).data();
    if (!m || m.fullTimeNotified === true) return false;
    tx.update(ref, { fullTimeNotified: true });
    return true;
  });
}

/** Did this update reach full time (organizer's whistle or completion)? */
export function reachedFullTime(before: DocumentData, after: DocumentData): boolean {
  const whistle = after.clock?.phase === 'full_time' && before.clock?.phase !== 'full_time';
  const completed = after.status === 'completed' && before.status !== 'completed';
  return (whistle || completed) && (after.score != null || after.clock != null);
}
