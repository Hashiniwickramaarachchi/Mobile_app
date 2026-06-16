const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || 'demo-project' });
const db = admin.firestore();

async function seed() {
  const seedPath = path.join(__dirname, '..', '..', 'firestore', 'seed-data.json');
  const raw = fs.readFileSync(seedPath, 'utf8');
  let data;
  try {
    data = JSON.parse(raw);
  } catch (e) {
    // support concatenated JSON objects: convert to array
    const wrapped = '[' + raw.replace(/}\s*\{/g, '},\n{') + ']';
    const arr = JSON.parse(wrapped);
    // merge array of objects into single object
    data = {};
    for (const obj of arr) {
      for (const [k, v] of Object.entries(obj)) {
        if (!data[k]) data[k] = [];
        if (Array.isArray(v)) data[k] = data[k].concat(v);
        else if (typeof v === 'object') {
          // if it's a map of docs, convert to array of docs with id
          for (const [docId, docVal] of Object.entries(v)) {
            data[k].push({ id: docId, ...docVal });
          }
        }
      }
    }
  }

  for (const [col, items] of Object.entries(data)) {
    if (!Array.isArray(items)) continue;
    for (const item of items) {
      const id = item.id;
      const doc = { ...item };
      delete doc.id;
      const ref = id ? db.collection(col).doc(id) : db.collection(col).doc();
      console.log('Writing', col, ref.id);
      await ref.set(doc, { merge: true });
    }
  }
  console.log('Seed complete');
}

seed().catch(err => { console.error(err); process.exit(1); });
