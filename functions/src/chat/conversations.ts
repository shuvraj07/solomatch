import { FieldValue, type DocumentData, type Firestore } from 'firebase-admin/firestore';

import { RuleError } from '../shared/rule_error.js';

/**
 * Conversations are created and their membership maintained only here, on
 * the server. Clients can read conversations they belong to, send messages
 * and update their own read marker (see firestore.rules).
 *
 *   conversations/match_{matchId}          group: organizer + roster
 *   conversations/dm_{matchId}_{playerId}  private: organizer ↔ player
 */

export const groupChatId = (matchId: string) => `match_${matchId}`;
export const directChatId = (matchId: string, playerId: string) => `dm_${matchId}_${playerId}`;

interface Member {
  name: string;
  photoUrl: string | null;
}

const member = (p: DocumentData | undefined): Member => ({
  name: p?.name ?? p?.fullName ?? 'Player',
  photoUrl: p?.photoUrl ?? null,
});

/**
 * Keeps the match group chat's members equal to organizer + roster.
 * Called when a roster entry is created or deleted.
 */
export async function syncGroupMember(
  db: Firestore,
  matchId: string,
  playerId: string,
  joined: DocumentData | undefined,
): Promise<void> {
  const matchRef = db.collection('matches').doc(matchId);
  const convRef = db.collection('conversations').doc(groupChatId(matchId));

  await db.runTransaction(async (tx) => {
    const [matchSnap, convSnap] = await tx.getAll(matchRef, convRef);
    const match = matchSnap.data();
    if (!match) return;
    const organizerId = match.organizer.uid as string;

    if (!convSnap.exists) {
      if (!joined) return; // nothing to leave
      tx.set(convRef, {
        type: 'group',
        matchId,
        title: match.title,
        participantIds: [organizerId],
        participants: { [organizerId]: member(match.organizer) },
        readAt: {},
        lastMessage: null,
        lastMessageAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    if (joined) {
      tx.set(
        convRef,
        {
          participantIds: FieldValue.arrayUnion(playerId),
          participants: { [playerId]: member(joined.player) },
        },
        { merge: true },
      );
    } else if (playerId !== organizerId) {
      tx.update(convRef, {
        participantIds: FieldValue.arrayRemove(playerId),
        [`participants.${playerId}`]: FieldValue.delete(),
      });
    }
  });
}

/**
 * Opens (creating if needed) the private chat between a match's organizer
 * and a player who asked to join or was added. Either of them may call it.
 */
export async function openDirectChat(
  db: Firestore,
  input: { matchId: string; playerId: string; callerUid: string },
): Promise<string> {
  const { matchId, playerId, callerUid } = input;
  const matchRef = db.collection('matches').doc(matchId);
  const convRef = db.collection('conversations').doc(directChatId(matchId, playerId));

  await db.runTransaction(async (tx) => {
    const [matchSnap, requestSnap, convSnap, playerSnap] = await tx.getAll(
      matchRef,
      matchRef.collection('requests').doc(playerId),
      convRef,
      db.collection('players').doc(playerId),
    );
    const match = matchSnap.data();
    if (!match) throw new RuleError('not-found', 'Match not found.');
    const organizerId = match.organizer.uid as string;
    if (callerUid !== organizerId && callerUid !== playerId) {
      throw new RuleError('permission-denied', 'You are not part of this conversation.');
    }
    if (playerId === organizerId) {
      throw new RuleError('invalid-argument', 'You organize this match.');
    }
    const [blockedByOrganizer, blockedByPlayer] = await tx.getAll(
      db.doc(`users/${organizerId}/blocks/${playerId}`),
      db.doc(`users/${playerId}/blocks/${organizerId}`),
    );
    if (blockedByOrganizer.exists || blockedByPlayer.exists) {
      throw new RuleError('permission-denied', "You can't message this player.");
    }
    if (!requestSnap.exists) {
      throw new RuleError('failed-precondition', 'Ask to join the match first, then you can message the organizer.');
    }
    if (convSnap.exists) return;

    const player = playerSnap.data();
    tx.set(convRef, {
      type: 'direct',
      matchId,
      title: match.title,
      participantIds: [organizerId, playerId],
      participants: {
        [organizerId]: member(match.organizer),
        [playerId]: member(player),
      },
      readAt: {},
      lastMessage: null,
      lastMessageAt: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return convRef.id;
}

export interface ChatPush {
  uid: string;
  title: string;
  body: string;
}

/** Who to push a new message to, and what it says. Pure. */
export function chatPushes(
  conversation: DocumentData,
  message: DocumentData,
): ChatPush[] {
  const sender = message.senderId as string;
  const senderName = (conversation.participants?.[sender]?.name as string) ?? 'Someone';
  const preview = message.imageUrl ? '📷 Photo' : (message.text as string);
  const isGroup = conversation.type === 'group';
  return (conversation.participantIds as string[])
    .filter((uid) => uid !== sender)
    .map((uid) => ({
      uid,
      title: isGroup ? `💬 ${conversation.title}` : senderName,
      body: isGroup ? `${senderName}: ${preview}` : preview,
    }));
}

/** Denormalized preview shown in the conversation list. */
export function lastMessagePreview(message: DocumentData) {
  return {
    senderId: message.senderId,
    text: message.imageUrl ? '📷 Photo' : String(message.text ?? '').slice(0, 140),
    sentAt: message.sentAt ?? FieldValue.serverTimestamp(),
  };
}
