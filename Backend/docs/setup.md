# Setup

Setup instructions for Backend (placeholder).
# Backend Setup

## 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

## 2. Set Your Firebase Project

Edit `.firebaserc` and replace:

```json
"replace-with-your-firebase-project-id"
```

with your Firebase project ID.

## 3. Install Function Dependencies

```bash
cd Backend/functions
npm install
```

## 4. Build Functions

```bash
npm run build
```

## 5. Run Emulators

From the `Backend` folder:

```bash
firebase emulators:start
```

## 6. Deploy

From the `Backend` folder:

```bash
firebase deploy
```

## Flutter Integration Notes

The Flutter app should use:

```yaml
firebase_core
firebase_auth
cloud_firestore
cloud_functions
```

Use Firebase Auth for signup/login. Store extra user data in Firestore under:

```text
users/{firebaseAuthUser.uid}
```
