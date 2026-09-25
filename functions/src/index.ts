import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { getStorage } from 'firebase-admin/storage';
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/firestore';
import { HttpsError, type CallableRequest, onCall } from 'firebase-functions/https';
import { setGlobalOptions } from 'firebase-functions/options';
import { onSchedule } from 'firebase-functions/scheduler';

import { deleteAccount } from './account/delete_account.js';
import {
  chatPushes,
  lastMessagePreview,
  openDirectChat,
  syncGroupMember,
} from './chat/conversations.js';
import { advanceMatches } from './matches/lifecycle.js';
import { parseLines, submitMatchReport } from './matches/match_report.js';
import { publishMatch } from './matches/publish_match.js';
import { deliver, pushToUser } from './notifications/deliver.js';
import { applyReview } from './reviews/aggregate.js';
import { forLineup, forMatchChange, forRequestChange } from './notifications/messages.js';
import { sendReminders } from './notifications/reminders.js';
import { acceptRequest, leaveMatch, rejectRequest } from './requests/join_requests.js';
import { isGroup } from './requests/slots.js';
import { RuleError } from './shared/rule_error.js';
import { bookedNotice, cancelBookingByVenue, releaseBooking } from './venues/bookings.js';
import { applyVenueRating } from './venues/ratings.js';
import {
  claimFullTime,
  fullTimeMessage,
  reachedFullTime,
  goalMessage,
  liveAudience,
  recomputeScore,
} from './live/live.js';

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
  if (result.bookedVenueId) {
    await deliver(
      db,
      getMessaging(),
      [
        bookedNotice(
          result.bookedVenueId,
          result.matchId,
          result.title,
          result.organizerName,
          result.startMs,
        ),
      ],
      `booked_${result.matchId}`,
    );
  }
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
  // Full time: tell players and followers the final score, once.
  if (reachedFullTime(before, after) && (await claimFullTime(db, matchId))) {
    const messaging = getMessaging();
    const audience = await liveAudience(db, matchId, after);
    const msg = fullTimeMessage(after, after.score ?? { home: 0, away: 0 });
    await Promise.all(
      audience.map((uid) =>
        pushToUser(db, messaging, uid, msg, {
          type: 'full_time',
          matchId,
          route: `/matches/${matchId}`,
        }),
      ),
    );
  }
  // A cancelled match gives its venue slot back.
  if (after.status === 'cancelled' && before.status !== 'cancelled') {
    items.push(...(await releaseBooking(db, matchId, after)));
  }
  await deliver(db, getMessaging(), items, event.id);
});

// ----------------------------------------------------------------------- chat

/** Roster changed → add/remove the player in the match group chat. */
export const onRosterWritten = onDocumentWritten(
  'matches/{matchId}/roster/{playerId}',
  async (event) => {
    const { matchId, playerId } = event.params;
    await syncGroupMember(getFirestore(), matchId, playerId, event.data?.after.data());
  },
);

/** Opens the organizer ↔ player chat: { matchId, playerId } → { conversationId }. */
export const openDirectConversation = onCall(async (req) => {
  const callerUid = requireUid(req);
  const matchId = requireString(req.data, 'matchId');
  const playerId = requireString(req.data, 'playerId');
  const conversationId = await run(() =>
    openDirectChat(getFirestore(), { matchId, playerId, callerUid }),
  );
  return { conversationId };
});

/** New message → update the conversation preview and push to the others. */
export const onChatMessageCreated = onDocumentCreated(
  'conversations/{conversationId}/messages/{messageId}',
  async (event) => {
    const message = event.data?.data();
    if (!message) return;
    const db = getFirestore();
    const ref = db.collection('conversations').doc(event.params.conversationId);
    const conversation = (await ref.get()).data();
    if (!conversation) return;

    await ref.update({
      lastMessage: lastMessagePreview(message),
      lastMessageAt: message.sentAt,
    });
    const messaging = getMessaging();
    await Promise.all(
      chatPushes(conversation, message).map((p) =>
        pushToUser(db, messaging, p.uid, { title: p.title, body: p.body }, {
          type: 'chat_message',
          route: `/chat/${ref.id}`,
          conversationId: ref.id,
        }),
      ),
    );
  },
);

// -------------------------------------------------------------------- reviews

/** New rating → update the player's average and let them know. */
export const onReviewCreated = onDocumentCreated('reviews/{reviewId}', async (event) => {
  const db = getFirestore();
  const note = await applyReview(db, event.params.reviewId);
  if (note) await deliver(db, getMessaging(), [note], event.id);
});

// -------------------------------------------------------------------- account

/** Permanently deletes the caller's account and personal data. */
export const deleteMyAccount = onCall({ timeoutSeconds: 300 }, async (req) => {
  const uid = requireUid(req);
  const bucket = getStorage().bucket();
  const summary = await deleteAccount(
    {
      db: getFirestore(),
      deleteAuthUser: (u) => getAuth().deleteUser(u),
      notify: async (items) => {
        for (const n of items) {
          await deliver(getFirestore(), getMessaging(), [n], `venue_closed_${n.matchId}`);
        }
      },
      deleteFiles: async (prefix) => {
        try {
          await bucket.deleteFiles({ prefix });
        } catch (e) {
          console.warn('deleteFiles failed', prefix, e);
        }
      },
    },
    uid,
  );
  return summary;
});

// --------------------------------------------------------------------- venues

/** Venue owner cancels a booked slot: { slotId, reason }. */
export const cancelVenueBooking = onCall(async (req) => {
  const ownerUid = requireUid(req);
  const slotId = requireString(req.data, 'slotId');
  const reason = (req.data as Record<string, unknown>)?.reason;
  const db = getFirestore();
  const items = await run(() =>
    cancelBookingByVenue(db, {
      ownerUid,
      slotId,
      reason: typeof reason === 'string' ? reason : '',
    }),
  );
  await deliver(db, getMessaging(), items, `venue_cancel_${ownerUid}_${slotId}`);
  return { ok: true };
});

/** New venue rating → update the venue's averages and tell the owner. */
export const onVenueRatingCreated = onDocumentCreated(
  'venues/{venueId}/ratings/{ratingId}',
  async (event) => {
    const db = getFirestore();
    const note = await applyVenueRating(db, event.params.venueId, event.params.ratingId);
    if (note) await deliver(db, getMessaging(), [note], event.id);
  },
);

// ----------------------------------------------------------------------- live

/** Live event added or undone → recount the score; push new goals. */
export const onMatchEventWritten = onDocumentWritten(
  'matches/{matchId}/events/{eventId}',
  async (event) => {
    const { matchId } = event.params;
    const db = getFirestore();
    const score = await recomputeScore(db, matchId);
    const created = !event.data?.before.exists ? event.data?.after.data() : undefined;
    if (created?.type !== 'goal') return;

    const match = (await db.collection('matches').doc(matchId).get()).data();
    if (!match) return;
    const messaging = getMessaging();
    const msg = goalMessage(match, created, score);
    const audience = (await liveAudience(db, matchId, match)).filter((u) => u !== created.by);
    await Promise.all(
      audience.map((uid) =>
        pushToUser(db, messaging, uid, msg, {
          type: 'live_goal',
          matchId,
          route: `/matches/${matchId}`,
        }),
      ),
    );
  },
);

/** Keeps `followerCount` on the match ("12 following"). */
export const onMatchFollowerWritten = onDocumentWritten(
  'matches/{matchId}/followers/{uid}',
  async (event) => {
    const before = event.data?.before.exists ?? false;
    const after = event.data?.after.exists ?? false;
    if (before === after) return;
    await getFirestore()
      .collection('matches')
      .doc(event.params.matchId)
      .update({ followerCount: FieldValue.increment(after ? 1 : -1) });
  },
);
