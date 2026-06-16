import { db } from './firebase';

const contactsCol = db.collection('contacts');

export async function createContact(data: any) {
  const ref = await contactsCol.add({ ...data, createdAt: Date.now() });
  const snap = await ref.get();
  return { id: ref.id, ...(snap.data() || {}) };
}

export async function getContact(id: string) {
  const snap = await contactsCol.doc(id).get();
  return snap.exists ? { id: snap.id, ...(snap.data() as any) } : null;
}

export async function listContactsForUser(userId: string) {
  const snaps = await contactsCol.where('userId', '==', userId).get();
  return snaps.docs.map(d => ({ id: d.id, ...(d.data() as any) }));
}

export async function updateContact(id: string, data: any) {
  await contactsCol.doc(id).set(data, { merge: true });
  return getContact(id);
}

export async function deleteContact(id: string) {
  await contactsCol.doc(id).delete();
  return { id };
}

