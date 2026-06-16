import { db } from './firebase';

const alertsCol = db.collection('alerts');

export async function createAlert(data: any) {
  const ref = await alertsCol.add({ ...data, createdAt: Date.now() });
  const snap = await ref.get();
  return { id: ref.id, ...(snap.data() || {}) };
}

export async function getAlert(id: string) {
  const snap = await alertsCol.doc(id).get();
  return snap.exists ? { id: snap.id, ...(snap.data() as any) } : null;
}

export async function listAlertsForUser(userId: string) {
  const snaps = await alertsCol.where('userId', '==', userId).orderBy('createdAt', 'desc').get();
  return snaps.docs.map(d => ({ id: d.id, ...(d.data() as any) }));
}

export async function deleteAlert(id: string) {
  await alertsCol.doc(id).delete();
  return { id };
}

