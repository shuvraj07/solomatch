/**
 * Who gets notified about what. Pure functions: they look at before/after
 * document data and return the notifications to send, so every rule is
 * unit-testable without Firestore or FCM.
 */

export type NotificationType =
  | 'new_request'
  | 'request_accepted'
  | 'request_rejected'
  | 'player_left'
  | 'match_almost_full'
  | 'match_full'
  | 'match_cancelled'
  | 'match_reminder'
  | 'motm_vote'
  | 'motm_won'
  | 'added_to_match'
  | 'request_expired'
  | 'kick_off'
  | 'report_reminder';

export interface Outgoing {
  uid: string;
  type: NotificationType;
  title: string;
  body: string;
  matchId: string;
}

type Doc = Record<string, any> | undefined;

const GROUP_LABELS: Record<string, string> = {
  gk: 'goalkeeper',
  def: 'defender',
  mid: 'midfielder',
  fwd: 'forward',
  any: 'any position',
};

/** "Sat 28 Sep, 6:00 pm" in Nepal time. */
export function kickOffLabel(ms: number): string {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Kathmandu',
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  }).format(new Date(ms));
}

/** A join request was created or changed. */
export function forRequestChange(
  matchId: string,
  playerId: string,
  before: Doc,
  after: Doc,
  match: Doc,
): Outgoing[] {
  if (!match || !after) return [];
  const title = match.title as string;
  const organizer = match.organizer?.uid as string;
  const was = before?.status as string | undefined;
  const now = after.status as string;
  const name = (after.player?.name as string) ?? 'A player';

  if (now === 'pending' && (was === undefined || was === 'cancelled')) {
    const group = GROUP_LABELS[after.preferredGroup] ?? 'any position';
    return [
      {
        uid: organizer,
        type: 'new_request',
        title: 'New join request',
        body: `${name} wants to play ${group} in ${title}.`,
        matchId,
      },
    ];
  }
  if (was === 'pending' && now === 'accepted') {
    return [
      {
        uid: playerId,
        type: 'request_accepted',
        title: "You're in! ⚽",
        body: `Your request to join ${title} was accepted.`,
        matchId,
      },
    ];
  }
  if (was === 'pending' && now === 'rejected') {
    return [
      {
        uid: playerId,
        type: 'request_rejected',
        title: 'Request not accepted',
        body: `Your request to join ${title} wasn't accepted this time.`,
        matchId,
      },
    ];
  }
  if (was === 'pending' && now === 'expired') {
    return [
      {
        uid: playerId,
        type: 'request_expired',
        title: 'Request expired',
        body: `${title} started before your request was accepted.`,
        matchId,
      },
    ];
  }
  if (was === 'accepted' && now === 'cancelled') {
    return [
      {
        uid: organizer,
        type: 'player_left',
        title: 'A player left',
        body: `${name} left ${title}. A spot is open again.`,
        matchId,
      },
    ];
  }
  return [];
}

export interface MatchAudience {
  /** Accepted players. */
  roster: string[];
  /** Players with a pending request. */
  pending: string[];
}

/** A match document changed. */
export function forMatchChange(
  matchId: string,
  before: Doc,
  after: Doc,
  audience: MatchAudience,
): Outgoing[] {
  if (!before || !after) return [];
  const title = after.title as string;
  const organizer = after.organizer?.uid as string;
  const out: Outgoing[] = [];
  const to = (uids: string[], n: Omit<Outgoing, 'uid' | 'matchId'>) =>
    uids.forEach((uid) => out.push({ uid, matchId, ...n }));

  if (before.status !== after.status) {
    switch (after.status) {
      case 'full':
        to([organizer], {
          type: 'match_full',
          title: 'Match full 🎉',
          body: `${title} has all ${after.maxPlayers} players.`,
        });
        break;
      case 'cancelled':
        to([...new Set([...audience.roster, ...audience.pending])], {
          type: 'match_cancelled',
          title: 'Match cancelled',
          body: `${title} on ${kickOffLabel(after.startAt.toMillis())} was cancelled by the organizer.`,
        });
        break;
      case 'started':
        to([...new Set([organizer, ...audience.roster])], {
          type: 'kick_off',
          title: 'Kick-off! ⚽',
          body: `${title} is starting now. Have a great game!`,
        });
        break;
      case 'completed':
        to(audience.roster, {
          type: 'motm_vote',
          title: 'Vote Man of the Match 🏆',
          body: `${title} is over. Who was the best player?`,
        });
        to([organizer], {
          type: 'report_reminder',
          title: 'Add the match report 📝',
          body: `How did ${title} go? Add goals, assists and cards within 24 hours.`,
        });
        break;
    }
  }

  if (
    after.status === 'filling' &&
    before.spotsRemaining > 2 &&
    after.spotsRemaining === 2
  ) {
    to([organizer], {
      type: 'match_almost_full',
      title: 'Almost full',
      body: `${title} has 2 spots left.`,
    });
  }

  if (!before.motm && after.motm) {
    const winners = (after.motm.winners as { uid: string }[]).map((w) => w.uid);
    to(winners, {
      type: 'motm_won',
      title: "You're Man of the Match! 🏆",
      body: `Your teammates voted you best player in ${title}.`,
    });
  }
  return out;
}

// ---------------------------------------------------------------- reminders

export const REMINDERS = [
  { key: 'h24', beforeMs: 24 * 60 * 60 * 1000, label: 'tomorrow' },
  { key: 'h2', beforeMs: 2 * 60 * 60 * 1000, label: 'in 2 hours' },
  { key: 'm30', beforeMs: 30 * 60 * 1000, label: 'in 30 minutes' },
] as const;

export type ReminderKey = (typeof REMINDERS)[number]['key'];

/**
 * The reminder to send now, if any: the tightest window we're inside that
 * hasn't been sent. Wider windows are marked sent at the same time, so a
 * match created 90 minutes ahead gets the 2-hour reminder and never a late
 * "tomorrow" one.
 */
export function dueReminder(
  startMs: number,
  nowMs: number,
  sent: Partial<Record<ReminderKey, boolean>> = {},
): { send: (typeof REMINDERS)[number]; markSent: ReminderKey[] } | null {
  const left = startMs - nowMs;
  if (left <= 0) return null;
  const inside = REMINDERS.filter((r) => left <= r.beforeMs);
  if (inside.length === 0) return null;
  const tightest = inside[inside.length - 1];
  if (sent[tightest.key]) return null;
  return { send: tightest, markSent: inside.map((r) => r.key) };
}

export function reminderMessage(
  match: Record<string, any>,
  reminder: (typeof REMINDERS)[number],
): Pick<Outgoing, 'type' | 'title' | 'body'> {
  const venue = match.venue?.name ? ` at ${match.venue.name}` : '';
  return {
    type: 'match_reminder',
    title:
      reminder.key === 'm30'
        ? 'Your football match starts in 30 minutes ⚽'
        : `Kick-off ${reminder.label} ⚽`,
    body: `${match.title}${venue}, ${kickOffLabel(match.startAt.toMillis())}.`,
  };
}

/** Organizer put these players on the roster when posting the match. */
export function forLineup(
  matchId: string,
  title: string,
  organizerName: string,
  startMs: number,
  uids: string[],
): Outgoing[] {
  return uids.map((uid) => ({
    uid,
    matchId,
    type: 'added_to_match',
    title: `${organizerName} added you to a match ⚽`,
    body: `${title}, ${kickOffLabel(startMs)}. Can't make it? Open the match and tap Leave.`,
  }));
}
