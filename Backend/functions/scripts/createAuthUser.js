const admin = require('firebase-admin');
const fetch = require('node-fetch');

process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || 'demo-project' });
const auth = admin.auth();

async function run() {
  const email = 'seeduser@example.com';
  const password = 'password123';
  const uid = 'user_1';

  try {
    await auth.getUser(uid);
    console.log('User already exists:', uid);
  } catch (e) {
    await auth.createUser({ uid, email, password });
    console.log('Created user', uid);
  }

  // Sign in via emulator REST to get ID token
  const signInUrl = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fakeKey';
  const resp = await fetch(signInUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, returnSecureToken: true })
  });
  const body = await resp.json();
  if (body.error) {
    console.error('Sign-in error', body);
    process.exit(1);
  }
  console.log('ID Token:', body.idToken);
}

run().catch(err => { console.error(err); process.exit(1); });
