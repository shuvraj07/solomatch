import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onDocumentUpdated, onDocumentWritten } from 'firebase-functions/firestore';
import { HttpsError, type CallableRequest, onCall } from 'firebase-functions/https';
import { setGlobalOptions } from 'firebase-functions/options';
import { onSchedule } from 'firebase-functions/scheduler';

import { advanceMatches } from './matches/lifecycle.js';
import { parseLines, submitMatchReport } from './matches/match_report.js';
import { publishMatch } from './matches/publish_match.js';
import { deliver } from './notifications/deliver.js';
import { forLineup, forMatchChange, forRequestChange } from './notifications/messages.js';
import { sendReminders } from './notifications/reminders.js';
import { acceptRequest, leaveMatch, rejectRequest } from './requests/join_requests.js';
import { isGroup } from './requests/slots.js';
import { RuleError } from './shared/rule_error.js';

initializeApp();

// Same region as Firestore (Mumbai) to keep transactions fast.
setGlobalOptions({ region: 'asia-south1', maxInstances: 10 });

function requireUid(req: CallableRequest): string {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  return uid;
}

function requireString(data: unknown, key: string): string {
  const value = (data as Record<string, unknown> | null)?.[key];
  if (typeof value !== 'string' || value.length === 0 || value.length > 128) {
    throw new HttpsError('invalid-argument', `Missing ${key}.`);
  }
  return value;
}

/** Runs domain logic, converting RuleErrors to HttpsErrors for the app. */
async function run<T>(action: () => Promise<T>): Promise<T> {
  try {
    return await action();
  } catch (e) {
    if (e instanceof RuleError) throw new HttpsError(e.code, e.message);
    throw e;
  }
}

/** Organizer accepts a pending request: { matchId, playerId, group? }. */
export const acceptJoinRequest = onCall((req) => {
  const callerUid = requireUid(req);
  const matchId = requireString(req.data, 'matchId');
  const playerId = requireString(req.data, 'playerId');
  const group = (req.data as Record<string, unknown>)?.group;
  if (group != null && !isGroup(group)) {
    throw new HttpsError('invalid-argument', 'Unknown position group.');
  }
  return run(() =>
    acceptRequest(getFirestore(), {
      matchId,
      playerId,
      callerUid,
      group: group ?? undefined,
    }),
  );
});

/** Organizer rejects a pending request: { matchId, playerId }. */
export const rejectJoinRequest = onCall(async (req) => {
  const callerUid = requireUid(req);
  const matchId = requireString(req.data, 'matchId');
  const playerId = requireString(req.data, 'playerId');
  await run(() => rejectRequest(getFirestore(), { matchId, playerId, callerUid }));
  return { ok: true };
});

/** Accepted player leaves before kick-off: { matchId }. */
export const leaveJoinedMatch = onCall(async (req) => {
  const callerUid = requireUid(req);
  const matchId = requireString(req.data, 'matchId');
  await run(() => leaveMatch(getFirestore(), { matchId, callerUid }));
  return { ok: true };
});

/**
 * Every 5 minutes: start matches at kick-off, complete them at the final
 * whistle (updating games played), decide Man of the Match when voting
 * closes, and send kick-off reminders.
 */
export const advanceMatchLifecycle = onSchedule(
  { schedule: 'every 5 minutes', timeZone: 'Asia/Kathmandu' },
  async () => {
    const db = getFirestore();
    const result = await advanceMatches(db);
    const reminders = await sendReminders(db, getMessaging());
    console.log('match lifecycle', { ...result, reminders });
  },
);

/** Organizer saves goals/assists/cards: { matchId, players: {uid: line} }. */
export const saveMatchReport = onCall(async (req) => {
  const callerUid = requireUid(req);
  const matchId = requireString(req.data, 'matchId');
  await run(async () =>
    submitMatchReport(getFirestore(), {
      matchId,
      callerUid,
      lines: parseLines((req.data as Record<string, unknown>)?.players),
    }),
  );
  return { ok: true };
});

/**
 * Publishes a saved draft: { draftId }. Places the organizer's confirmed
 * players on the roster and tells them they were added.
 */
export const publishDraft = onCall(async (req) => {
  const callerUid = requireUid(req);
  const draftId = requireString(req.data, 'draftId');
  const db = getFirestore();
  const result = await run(() => publishMatch(db, { draftId, callerUid }));
  const match = (await db.collection('matches').doc(result.matchId).get()).data();
  await deliver(
    db,
    getMessaging(),
    forLineup(
      result.matchId,
      result.title,
      result.organizerName,
      match?.startAt?.toMillis() ?? Date.now(),
      result.addedPlayers,
    ),
    `added_${result.matchId}`,
  );
  return { matchId: result.matchId, currentPlayers: result.currentPlayers };
});

// ------------------------------------------------------------- notifications

/** Join request created or changed → notify organizer or player. */
export const onJoinRequestWritten = onDocumentWritten(
  'matches/{matchId}/requests/{playerId}',
  async (event) => {
    const { matchId, playerId } = event.params;
    const db = getFirestore();
    const match = (await db.collection('matches').doc(matchId).get()).data();
    const items = forRequestChange(
      matchId,
      playerId,
      event.data?.before.data(),
      event.data?.after.data(),
      match,
    );
    await deliver(db, getMessaging(), items, event.id);
  },
);

/** Match status/capacity/MOTM changed → notify the people involved. */
export const onMatchUpdated = onDocumentUpdated('matches/{matchId}', async (event) => {
  const { matchId } = event.params;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const needsAudience = before.status !== after.status;
  const db = getFirestore();
  const ref = db.collection('matches').doc(matchId);
  const [roster, pending] = needsAudience
    ? await Promise.all([
        ref.collection('roster').get(),
        ref.collection('requests').where('status', '==', 'pending').get(),
      ])
    : [null, null];

  const items = forMatchChange(matchId, before, after, {
    roster: roster?.docs.map((d) => d.id) ?? [],
    pending: pending?.docs.map((d) => d.id) ?? [],
  });
  await deliver(db, getMessaging(), items, event.id);
});
