import { type DocumentData, FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';

import { type Group, GROUPS, type Slots, isGroup, pickGroup } from '../requests/slots.js';
import { RuleError } from '../shared/rule_error.js';
import { type BookedSlot, readSlotForBooking } from '../venues/bookings.js';

/**
 * Publishes a draft as a match. Server-side because the organizer may bring
 * players who are already confirmed ("lineup"), and only the server may
 * write roster entries and counters.
 *
 * The draft is re-validated here (the app's checks are only for fast
 * feedback). In one transaction it writes:
 *   - matches/{id} with counters/slots reflecting the pre-filled players
 *   - roster + an `accepted` request for each lineup player (so the match
 *     shows in their My Matches and they can leave)
 *   - the booked venue slot, if the organizer picked one (venue and times
 *     then come from the venue's slot, not the draft)
 *   - deletes the draft
 */

const FORMATS = ['fiveASide', 'sevenASide', 'nineASide', 'elevenASide'];
const SKILLS = ['beginner', 'intermediate', 'advanced', 'any'];
const MIN_MS = 60 * 1000;

export interface PublishResult {
  matchId: string;
  currentPlayers: number;
  /** Lineup players (not guests) to notify. */
  addedPlayers: string[];
  title: string;
  organizerName: string;
  /** Set when a venue slot was booked: the venue (= owner uid) to notify. */
  bookedVenueId: string | null;
  startMs: number;
}

const fail = (message: string): never => {
  throw new RuleError('invalid-argument', message);
};

function str(v: unknown, label: string, min: number, max: number): string {
  if (typeof v !== 'string') return fail(`Missing ${label}.`);
  const s = v.trim();
  if (s.length < min || s.length > max) fail(`${label} must be ${min}–${max} characters.`);
  return s;
}

function int(v: unknown, label: string, min: number, max: number): number {
  if (!Number.isInteger(v) || (v as number) < min || (v as number) > max) {
    fail(`${label} must be between ${min} and ${max}.`);
  }
  return v as number;
}

function card(uid: string, p: DocumentData) {
  const stats = p.stats ?? {};
  return {
    uid,
    name: p.fullName,
    username: p.username,
    photoUrl: p.photoUrl ?? null,
    primaryPosition: p.primaryPosition,
    secondaryPositions: p.secondaryPositions ?? [],
    skillLevel: p.skillLevel,
    ratingAvg: stats.ratingAvg ?? 0,
    ratingCount: stats.ratingCount ?? 0,
    gamesPlayed: stats.gamesPlayed ?? 0,
  };
}

const POSITION_GROUP: Record<string, Group> = {
  goalkeeper: 'gk',
  centerBack: 'def',
  fullBack: 'def',
  defensiveMidfielder: 'mid',
  centralMidfielder: 'mid',
  attackingMidfielder: 'mid',
  winger: 'fwd',
  striker: 'fwd',
};

export async function publishMatch(
  db: Firestore,
  input: { draftId: string; callerUid: string },
  now: Date = new Date(),
): Promise<PublishResult> {
  const draftRef = db.collection('match_drafts').doc(input.draftId);
  const matchRef = db.collection('matches').doc(input.draftId);

  return db.runTransaction(async (tx) => {
    const draft = (await tx.get(draftRef)).data();
    if (!draft) throw new RuleError('not-found', 'Draft not found. Save it and try again.');
    if (draft.organizerId !== input.callerUid) {
      throw new RuleError('permission-denied', 'Only the organizer can publish this match.');
    }
    if ((await tx.get(matchRef)).exists) {
      throw new RuleError('failed-precondition', 'This match is already published.');
    }

    // ---- validate the draft ----
    const title = str(draft.title, 'Title', 3, 80);
    const booked: BookedSlot | null = draft.booking
      ? await readSlotForBooking(db, tx, draft.booking, input.callerUid, now)
      : null;
    let venue: Record<string, unknown>;
    if (booked) {
      venue = booked.venue;
    } else {
      const v = draft.venue ?? fail('Add a venue.');
      venue = {
        name: str(v.name, 'Venue name', 1, 80),
        address: typeof v.address === 'string' ? v.address.trim().slice(0, 120) : '',
        city: str(v.city, 'City', 1, 60),
        placeId: typeof v.placeId === 'string' ? v.placeId : null,
        lat: typeof v.lat === 'number' ? v.lat : null,
        lng: typeof v.lng === 'number' ? v.lng : null,
      };
      if (!(draft.startAt instanceof Timestamp) || !(draft.endAt instanceof Timestamp)) {
        fail('Pick a date and time.');
      }
    }
    const startAt = booked?.startAt ?? (draft.startAt as Timestamp);
    const endAt = booked?.endAt ?? (draft.endAt as Timestamp);
    if (startAt.toMillis() <= now.getTime()) fail('Kick-off must be in the future.');
    const length = endAt.toMillis() - startAt.toMillis();
    if (length < 30 * MIN_MS || length > 360 * MIN_MS) fail('Matches must last 30 minutes to 6 hours.');
    if (!FORMATS.includes(draft.format)) fail('Unknown format.');
    const maxPlayers = int(draft.maxPlayers, 'Players', 2, 30);
    if (!SKILLS.includes(draft.skillLevel)) fail('Unknown skill level.');
    const price = int(draft.priceAmount ?? 0, 'Price', 0, 100000);
    const description = typeof draft.description === 'string' ? draft.description.trim() : '';
    const rules = typeof draft.rules === 'string' ? draft.rules.trim() : '';
    if (description.length > 1000 || rules.length > 1000) fail('Description and rules: 1000 characters max.');
    const photos: string[] = Array.isArray(draft.photos) ? draft.photos : [];
    if (photos.length > 5 || photos.some((p) => typeof p !== 'string')) fail('Up to 5 photos.');

    const needed = (draft.neededPositions ?? {}) as Record<string, unknown>;
    const slots = {} as Slots;
    let specific = 0;
    for (const g of GROUPS.filter((g) => g !== 'any')) {
      const n = needed[g] == null ? 0 : int(needed[g], 'Positions', 0, maxPlayers);
      slots[g] = { needed: n, filled: 0 };
      specific += n;
    }
    if (specific > maxPlayers) fail('Positions add up to more than the number of players.');
    slots.any = { needed: maxPlayers - specific, filled: 0 };

    // ---- confirmed players ----
    const organizerSnap = await tx.get(db.collection('players').doc(input.callerUid));
    const organizer = organizerSnap.data() ?? fail('Finish your profile first.');

    const lineupIn: { uid: string; group?: string }[] = Array.isArray(draft.lineup) ? draft.lineup : [];
    const uids = lineupIn.map((l) => l.uid);
    if (new Set(uids).size !== uids.length) fail('A player is listed twice.');
    if (uids.includes(input.callerUid)) fail('Use "I\'m playing too" to add yourself.');
    const guestCount = draft.guestCount == null ? 0 : int(draft.guestCount, 'Guests', 0, maxPlayers);

    const playerSnaps = uids.length
      ? await tx.getAll(...uids.map((u) => db.collection('players').doc(u)))
      : [];
    const roster: { uid: string; player: ReturnType<typeof card>; group: Group }[] = [];
    const place = (wanted: unknown, fallback: Group): Group => {
      const g = pickGroup(slots, isGroup(wanted) ? wanted : fallback, false);
      slots[g].filled += 1;
      return g;
    };

    if (draft.organizerPlaying === true) {
      const player = card(input.callerUid, organizer);
      roster.push({
        uid: input.callerUid,
        player,
        group: place(draft.organizerGroup, POSITION_GROUP[organizer.primaryPosition] ?? 'any'),
      });
    }
    playerSnaps.forEach((snap, i) => {
      const p = snap.data() ?? fail('One of the selected players no longer exists.');
      roster.push({
        uid: snap.id,
        player: card(snap.id, p),
        group: place(lineupIn[i].group, POSITION_GROUP[p.primaryPosition] ?? 'any'),
      });
    });
    for (let i = 0; i < guestCount; i++) place('any', 'any');

    const currentPlayers = roster.length + guestCount;
    if (currentPlayers > maxPlayers) fail('More confirmed players than places.');

    // ---- write everything ----
    const ts = FieldValue.serverTimestamp();
    tx.create(matchRef, {
      organizer: {
        uid: input.callerUid,
        name: organizer.fullName,
        username: organizer.username,
        photoUrl: organizer.photoUrl ?? null,
      },
      title,
      searchTitle: title.toLowerCase(),
      venue,
      startAt,
      endAt,
      format: draft.format,
      maxPlayers,
      currentPlayers,
      spotsRemaining: maxPlayers - currentPlayers,
      guestCount,
      slots,
      skillLevel: draft.skillLevel,
      price: { amount: price, currency: 'NPR', isFree: price === 0 },
      isIndoor: booked ? booked.isIndoor : draft.isIndoor === true,
      ...(booked
        ? { booking: { venueId: booked.venueId, slotId: booked.slotId, status: 'confirmed' } }
        : {}),
      description,
      rules,
      photos,
      status: currentPlayers >= maxPlayers ? 'full' : currentPlayers > 0 ? 'filling' : 'published',
      createdAt: ts,
      updatedAt: ts,
    });
    if (booked) {
      tx.update(booked.slotRef, {
        status: 'booked',
        booking: {
          matchId: matchRef.id,
          matchTitle: title,
          organizerId: input.callerUid,
          organizerName: organizer.fullName,
          bookedAt: ts,
        },
      });
    }
    const snapshot = { title, startAt, venueName: venue.name };
    for (const r of roster) {
      tx.set(matchRef.collection('roster').doc(r.uid), {
        player: r.player,
        group: r.group,
        joinedAt: ts,
        addedByOrganizer: true,
      });
      tx.set(matchRef.collection('requests').doc(r.uid), {
        status: 'accepted',
        player: r.player,
        preferredGroup: r.group,
        assignedGroup: r.group,
        message: '',
        match: snapshot,
        addedByOrganizer: true,
        createdAt: ts,
        updatedAt: ts,
        decidedAt: ts,
      });
    }
    tx.delete(draftRef);

    return {
      matchId: matchRef.id,
      currentPlayers,
      addedPlayers: roster.map((r) => r.uid).filter((u) => u !== input.callerUid),
      title,
      organizerName: organizer.fullName,
      bookedVenueId: booked?.venueId ?? null,
      startMs: startAt.toMillis(),
    };
  });
}
