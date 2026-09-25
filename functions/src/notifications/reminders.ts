import { Timestamp, type Firestore } from 'firebase-admin/firestore';

import { deliver, type PushSender } from './deliver.js';
import { REMINDERS, dueReminder, reminderMessage } from './messages.js';

const UPCOMING = ['published', 'filling', 'full'];

/**
 * Sends 24 h / 2 h / 30 min kick-off reminders to the organizer and every
 * accepted player. Called from the 5-minute scheduled job. Each reminder
 * is claimed in a transaction first, so it goes out once.
 */
export async function sendReminders(
  db: Firestore,
  push: PushSender,
  now: Date = new Date(),
): Promise<number> {
  const horizon = Timestamp.fromMillis(now.getTime() + REMINDERS[0].beforeMs);
  const soon = await db
    .collection('matches')
    .where('status', 'in', UPCOMING)
    .where('startAt', '>', Timestamp.fromDate(now))
    .where('startAt', '<=', horizon)
    .get();

  let sent = 0;
  for (const doc of soon.docs) {
    const claimed = await db.runTransaction(async (tx) => {
      const m = (await tx.get(doc.ref)).data();
      if (!m || !UPCOMING.includes(m.status)) return null;
      const due = dueReminder(m.startAt.toMillis(), now.getTime(), m.remindersSent ?? {});
      if (!due) return null;
      tx.update(doc.ref, Object.fromEntries(due.markSent.map((k) => [`remindersSent.${k}`, true])));
      return { match: m, reminder: due.send };
    });
    if (!claimed) continue;

    const roster = await doc.ref.collection('roster').get();
    const uids = [claimed.match.organizer.uid, ...roster.docs.map((d) => d.id)];
    const message = reminderMessage(claimed.match, claimed.reminder);
    sent += await deliver(
      db,
      push,
      uids.map((uid) => ({ uid, matchId: doc.id, ...message })),
      `reminder_${doc.id}_${claimed.reminder.key}`,
    );
  }
  return sent;
}
