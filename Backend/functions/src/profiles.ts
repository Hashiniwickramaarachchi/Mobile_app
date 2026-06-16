import { db } from './firebase';

const profilesCol = db.collection('profiles');

export async function createProfile(data: any) {
  const ref = await profilesCol.add({ ...data, createdAt: Date.now() });
  const snap = await ref.get();
  return { id: ref.id, ...(snap.data() || {}) };
}

export async function getProfile(id: string) {
  const snap = await profilesCol.doc(id).get();
  return snap.exists ? { id: snap.id, ...(snap.data() as any) } : null;
}

export async function updateProfile(id: string, data: any) {
  await profilesCol.doc(id).set(data, { merge: true });
  return getProfile(id);
}

export async function deleteProfile(id: string) {
  await profilesCol.doc(id).delete();
  return { id };
}

