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
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if ((e as { code?: number }).code === ALREADY_EXISTS) continue;
      throw e;
    }

    const devices = await user.collection('devices').get();
    const tokens = devices.docs.map((d) => d.id);
    if (tokens.length === 0) continue;

    const result = await push.sendEachForMulticast({
      tokens,
      notification: { title: n.title, body: n.body },
      data: {
        type: n.type,
        matchId: n.matchId,
        route: `/matches/${n.matchId}`,
        notificationId: inbox.id,
      },
      android: { priority: 'high' },
    });
    sent++;

    // Forget tokens for uninstalled apps / expired registrations.
    const dead = result.responses
      .map((r, i) => (!r.success && DEAD_TOKEN_CODES.has(r.error?.code ?? '') ? tokens[i] : null))
      .filter((t): t is string => t !== null);
    await Promise.all(dead.map((t) => user.collection('devices').doc(t).delete()));
  }
  return sent;
}
