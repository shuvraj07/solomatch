import { FieldValue, type Firestore } from 'firebase-admin/firestore';

import type { Outgoing } from './messages.js';

/** The slice of firebase-admin Messaging we use (injectable for tests). */
export interface PushSender {
  sendEachForMulticast(message: {
    tokens: string[];
    notification: { title: string; body: string };
    data: Record<string, string>;
    android?: Record<string, unknown>;
  }): Promise<{
    responses: { success: boolean; error?: { code: string } }[];
  }>;
}

const DEAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

const ALREADY_EXISTS = 6; // gRPC status

/**
 * Writes each notification to the recipient's inbox and pushes it to
 * their devices.
 *
 * [idPrefix] makes delivery idempotent: Cloud Functions triggers can run
 * more than once for the same event, so the inbox doc ID is derived from
 * the event and a second attempt finds it already there and sends nothing.
 */
export async function deliver(
  db: Firestore,
  push: PushSender,
  items: Outgoing[],
  idPrefix: string,
): Promise<number> {
  let sent = 0;
  for (const n of items) {
    if (!n.uid) continue;
    const user = db.collection('users').doc(n.uid);
    const inbox = user.collection('notifications').doc(`${idPrefix}_${n.uid}_${n.type}`);
    try {
      await inbox.create({
        type: n.type,
        title: n.title,
        body: n.body,
        matchId: n.matchId,
        ...(n.route ? { route: n.route } : {}),
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if ((e as { code?: number }).code === ALREADY_EXISTS) continue;
      throw e;
    }

    await pushToUser(db, push, n.uid, { title: n.title, body: n.body }, {
      type: n.type,
      matchId: n.matchId,
      route: n.route ?? `/matches/${n.matchId}`,
      notificationId: inbox.id,
    });
    sent++;
  }
  return sent;
}

/**
 * Pushes to every registered device of [uid] (no inbox entry). Returns
 * true if the user had any devices. Tokens FCM rejects as dead are removed.
 */
export type NotificationCategory = 'requests' | 'matches' | 'chat' | 'reviews';

/** Which settings toggle controls a notification type. */
export function categoryOf(type: string): NotificationCategory {
  switch (type) {
    case 'new_request':
    case 'request_accepted':
    case 'request_rejected':
    case 'request_expired':
    case 'player_left':
    case 'added_to_match':
      return 'requests';
    case 'chat_message':
      return 'chat';
    case 'new_review':
    case 'new_venue_rating':
    case 'motm_vote':
    case 'motm_won':
      return 'reviews';
    // live_goal, full_time and everything else about a match.
    default:
      return 'matches';
  }
}

export async function pushToUser(
  db: Firestore,
  push: PushSender,
  uid: string,
  notification: { title: string; body: string },
  data: Record<string, string>,
): Promise<boolean> {
  const user = db.collection('users').doc(uid);
  const prefs = (await user.get()).data()?.notificationPrefs ?? {};
  if (prefs[categoryOf(data.type ?? '')] === false) return false;

  const devices = user.collection('devices');
  const tokens = (await devices.get()).docs.map((d) => d.id);
  if (tokens.length === 0) return false;

  const result = await push.sendEachForMulticast({
    tokens,
    notification,
    data,
    android: { priority: 'high' },
  });
  const dead = result.responses
    .map((r, i) => (!r.success && DEAD_TOKEN_CODES.has(r.error?.code ?? '') ? tokens[i] : null))
    .filter((t): t is string => t !== null);
  await Promise.all(dead.map((t) => devices.doc(t).delete()));
  return true;
}
