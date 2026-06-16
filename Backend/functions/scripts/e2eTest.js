const admin = require('firebase-admin');
const fetch = require('node-fetch');
const path = require('path');

async function run() {
  process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8081';
  process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || 'replace-with-your-firebase-project-id';

  admin.initializeApp({ projectId });
  const db = admin.firestore();

  // 1) Ensure seed exists (we assume seed script already ran)
  console.log('Checking seeded user user_1...');
  const u = await db.collection('users').doc('user_1').get();
  console.log('Seeded user exists:', u.exists);

  // 2) Create auth user (if not exists) and sign in to get ID token
  const email = 'e2euser@example.com';
  const password = 'password123';
  try { await admin.auth().getUserByEmail(email); console.log('Auth user exists'); } catch (e) { await admin.auth().createUser({ email, password }); console.log('Created auth user'); }

  // Sign in via emulator REST to get ID token
  const signInUrl = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fakeKey';
  const resp = await fetch(signInUrl, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, returnSecureToken: true })
  });
  const body = await resp.json();
  if (body.error) throw new Error('Sign-in failed: ' + JSON.stringify(body));
  const idToken = body.idToken;
  console.log('Obtained ID token');

  // 3) Call protected endpoint to create a new user document via API
  const apiUrl = `http://127.0.0.1:5001/${projectId}/us-central1/api/users`;
  const createResp = await fetch(apiUrl, {
    method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + idToken },
    body: JSON.stringify({ name: 'E2E Created', email: 'e2e-created@example.com' })
  });
  const created = await createResp.json();
  console.log('API create response:', created);
  if (!created.id) throw new Error('API did not return created id');

  // 4) Verify in Firestore
  const doc = await db.collection('users').doc(created.id).get();
  console.log('Verified created doc exists:', doc.exists, 'data:', doc.data());

  console.log('E2E test completed successfully');
}

run().catch(err => { console.error(err); process.exit(1); });
