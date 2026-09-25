import { RuleError } from '../shared/rule_error.js';

export const GROUPS = ['gk', 'def', 'mid', 'fwd', 'any'] as const;
export type Group = (typeof GROUPS)[number];

export type Slots = Record<Group, { needed: number; filled: number }>;

const LABELS: Record<Group, string> = {
  gk: 'goalkeeper',
  def: 'defender',
  mid: 'midfielder',
  fwd: 'forward',
  any: 'any-position',
};

export function isGroup(value: unknown): value is Group {
  return typeof value === 'string' && (GROUPS as readonly string[]).includes(value);
}

export function openIn(slots: Slots, group: Group): number {
  const s = slots[group];
  return s ? Math.max(0, s.needed - s.filled) : 0;
}

/**
 * Chooses the roster slot for an accepted player.
 *
 * - `strict` (organizer picked a group): that group must have room.
 * - otherwise: the player's preferred group, then ANY, then any open group.
 *   The organizer already chose this player, so we never block on position
 *   while the match as a whole has room.
 */
export function pickGroup(slots: Slots, wanted: Group, strict: boolean): Group {
  if (openIn(slots, wanted) > 0) return wanted;
  if (strict) {
    throw new RuleError(
      'failed-precondition',
      `No ${LABELS[wanted]} spots left.`,
    );
  }
  const fallback = [wanted, 'any', ...GROUPS].find(
    (g): g is Group => isGroup(g) && openIn(slots, g) > 0,
  );
  if (!fallback) throw new RuleError('failed-precondition', 'This match is full.');
  return fallback;
}
