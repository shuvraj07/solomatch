import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { Timestamp, serverTimestamp } from 'firebase/firestore';

export const PROJECT_ID = 'demo-solomatch';

export async function createTestEnv() {
  const rulesPath = new URL('../../../firestore.rules', import.meta.url);
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(rulesPath, 'utf8') },
  });
}

/** Firestore client acting as a signed-in user. */
export function db(env, uid, email = `${uid}@example.com`) {
  return env.authenticatedContext(uid, { email }).firestore();
}

/** A valid `players/{uid}` create payload, matching PlayerProfileMapper. */
export function profileDoc(overrides = {}) {
  return {
    fullName: 'Raj Shrestha',
    searchName: 'raj shrestha',
    username: 'raj10',
    photoUrl: null,
    dateOfBirth: Timestamp.fromDate(new Date(Date.UTC(1998, 4, 12))),
    city: 'Kathmandu',
    bio: '',
    primaryPosition: 'centralMidfielder',
    secondaryPositions: ['attackingMidfielder'],
    skillLevel: 'intermediate',
    preferredFoot: 'right',
    heightCm: null,
    yearsPlaying: 6,
    languages: ['Nepali', 'English'],
    availability: ['6.evening'],
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}
