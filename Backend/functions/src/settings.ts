import { db } from './firebase';

const settingsCol = db.collection('settings');

export async function getSettings(userId: string) {
  const snap = await settingsCol.doc(userId).get();
  return snap.exists ? (snap.data() as any) : {};
}

export async function updateSettings(userId: string, data: any) {
  await settingsCol.doc(userId).set({ ...data, updatedAt: Date.now() }, { merge: true });
  return getSettings(userId);
}

export async function deleteSettings(userId: string) {
  await settingsCol.doc(userId).delete();
  return { userId };
}

