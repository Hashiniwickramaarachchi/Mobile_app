const fs = require('fs');
const fetch = require('node-fetch');
const path = require('path');

async function upload() {
  const rulesPath = path.join(__dirname, '..', '..', 'firestore', 'firestore.rules');
  const content = fs.readFileSync(rulesPath, 'utf8');
  const projectId = 'replace-with-your-firebase-project-id';
  const url = `http://127.0.0.1:8080/emulator/v1/projects/${projectId}:securityRules`;

  const body = { rules: { files: [{ name: 'security.rules', content }] }, ignore_errors: true };

  const resp = await fetch(url, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  const text = await resp.text();
  console.log('Upload rules status', resp.status, text);
}

upload().catch(err => { console.error(err); process.exit(1); });
