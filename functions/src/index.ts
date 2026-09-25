import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest, onCall } from 'firebase-functions/https';
import { setGlobalOptions } from 'firebase-functions/options';

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
