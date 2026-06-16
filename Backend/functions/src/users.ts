import { db } from './firebase';

const usersCol = db.collection('users');

export async function createUser(data: any) {
  const ref = await usersCol.add({ ...data, createdAt: Date.now() });
  const snap = await ref.get();
  return { id: ref.id, ...(snap.data() || {}) };
}

export async function getUser(id: string) {
  const snap = await usersCol.doc(id).get();
  return snap.exists ? { id: snap.id, ...(snap.data() as any) } : null;
}

export async function updateUser(id: string, data: any) {
  await usersCol.doc(id).set(data, { merge: true });
  return getUser(id);
}

export async function deleteUser(id: string) {
  await usersCol.doc(id).delete();
  return { id };
}

