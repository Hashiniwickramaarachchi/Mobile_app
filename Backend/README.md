# Backend

This backend is implemented as Firebase Cloud Functions with a small Express API and Firestore as the database.

Quick start (inside `Backend/functions`):

```bash
cd Backend/functions
npm install
npm run build
# emulators or deploy
firebase emulators:start --only functions,firestore
# or
firebase deploy --only functions,firestore
```

Endpoints (exported as `api` function):
- `POST /users` - create user
- `GET /users/:id` - get user
- `PATCH /users/:id` - update user
- `DELETE /users/:id` - delete user

Also: `profiles`, `contacts`, `alerts`, `settings` similar CRUD endpoints.
