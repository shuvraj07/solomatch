import { type DocumentData, FieldValue, type Firestore } from 'firebase-admin/firestore';

import { RuleError } from '../shared/rule_error.js';
import { type Group, type Slots, isGroup, pickGroup } from './slots.js';

/**
 * Roster changes. Each runs in a Firestore transaction: reads see a
 * consistent snapshot, and if another transaction changes the match first
 * this one retries against the new data. That is what guarantees a match
 * can never go over maxPlayers, however many accepts race each other.
 */

const OPEN_STATUSES = ['published', 'filling'];

function refs(db: Firestore, matchId: string, playerId: string) {
  const match = db.collection('matches').doc(matchId);
  return {
    match,
    request: match.collection('requests').doc(playerId),
    roster: match.collection('roster').doc(playerId),
  };
}

function assertBeforeKickOff(match: DocumentData) {
  if (match.startAt.toMillis() <= Date.now()) {
    throw new RuleError('failed-precondition', 'This match has already started.');
  }
}

export interface AcceptInput {
  matchId: string;
  playerId: string;
  callerUid: string;
  /** Slot chosen by the organizer; defaults to the player's preference. */
  group?: Group;
}

export async function acceptRequest(db: Firestore, input: AcceptInput) {
  const r = refs(db, input.matchId, input.playerId);

  return db.runTransaction(async (tx) => {
    const [matchSnap, requestSnap] = await tx.getAll(r.match, r.request);
    const match = matchSnap.data();
    if (!match) throw new RuleError('not-found', 'Match not found.');
    if (match.organizer?.uid !== input.callerUid) {
      throw new RuleError('permission-denied', 'Only the organizer can accept players.');
    }
    const request = requestSnap.data();
    if (!request) throw new RuleError('not-found', 'Request not found.');
    if (request.status !== 'pending') {
      throw new RuleError('failed-precondition', `This request was already ${request.status}.`);
    }
    if (match.currentPlayers >= match.maxPlayers || match.status === 'full') {
      throw new RuleError('failed-precondition', 'This match is full.');
    }
    if (!OPEN_STATUSES.includes(match.status)) {
      throw new RuleError('failed-precondition', 'This match is no longer taking players.');
    }
    assertBeforeKickOff(match);

    const slots = match.slots as Slots;
    const preferred: Group = isGroup(request.preferredGroup) ? request.preferredGroup : 'any';
    const group = pickGroup(slots, input.group ?? preferred, input.group != null);
    const currentPlayers = match.currentPlayers + 1;
    const now = FieldValue.serverTimestamp();

    tx.set(r.roster, { player: request.player, group, joinedAt: now });
    tx.update(r.request, {
      status: 'accepted',
      assignedGroup: group,
      decidedAt: now,
      updatedAt: now,
    });
    tx.update(r.match, {
      currentPlayers,
      spotsRemaining: match.maxPlayers - currentPlayers,
      [`slots.${group}.filled`]: slots[group].filled + 1,
      status: currentPlayers >= match.maxPlayers ? 'full' : 'filling',
      updatedAt: now,
    });
    return { group, currentPlayers };
  });
}

export interface DecideInput {
  matchId: string;
  playerId: string;
  callerUid: string;
}

export async function rejectRequest(db: Firestore, input: DecideInput) {
  const r = refs(db, input.matchId, input.playerId);

  await db.runTransaction(async (tx) => {
    const [matchSnap, requestSnap] = await tx.getAll(r.match, r.request);
    const match = matchSnap.data();
    if (!match) throw new RuleError('not-found', 'Match not found.');
    if (match.organizer?.uid !== input.callerUid) {
      throw new RuleError('permission-denied', 'Only the organizer can reject players.');
    }
    const request = requestSnap.data();
    if (!request) throw new RuleError('not-found', 'Request not found.');
    if (request.status !== 'pending') {
      throw new RuleError('failed-precondition', `This request was already ${request.status}.`);
    }
    const now = FieldValue.serverTimestamp();
    tx.update(r.request, { status: 'rejected', decidedAt: now, updatedAt: now });
  });
}

export interface LeaveInput {
  matchId: string;
  callerUid: string;
}

/** An accepted player drops out; their place reopens. */
export async function leaveMatch(db: Firestore, input: LeaveInput) {
  const r = refs(db, input.matchId, input.callerUid);

  await db.runTransaction(async (tx) => {
    const [matchSnap, rosterSnap] = await tx.getAll(r.match, r.roster);
    const match = matchSnap.data();
    if (!match) throw new RuleError('not-found', 'Match not found.');
    const entry = rosterSnap.data();
    if (!entry) throw new RuleError('failed-precondition', "You're not in this match.");
    if (!['published', 'filling', 'full'].includes(match.status)) {
      throw new RuleError('failed-precondition', 'This match can no longer be changed.');
    }
    assertBeforeKickOff(match);

    const group = entry.group as Group;
    const slots = match.slots as Slots;
    const currentPlayers = Math.max(0, match.currentPlayers - 1);
    const now = FieldValue.serverTimestamp();

    tx.delete(r.roster);
    tx.set(
      r.request,
      { status: 'cancelled', leftAt: now, updatedAt: now },
      { merge: true },
    );
    tx.update(r.match, {
      currentPlayers,
      spotsRemaining: match.maxPlayers - currentPlayers,
      [`slots.${group}.filled`]: Math.max(0, slots[group].filled - 1),
      status: currentPlayers === 0 ? 'published' : 'filling',
      updatedAt: now,
    });
  });
}
