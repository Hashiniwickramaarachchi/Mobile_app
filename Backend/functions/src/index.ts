import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
import { requireAuth } from './middleware/auth';
import {
  createUser,
  getUser,
  updateUser,
  deleteUser
} from './users';
import {
  createProfile,
  getProfile,
  updateProfile,
  deleteProfile
} from './profiles';
import {
  createContact,
  getContact,
  listContactsForUser,
  updateContact,
  deleteContact
} from './contacts';
import { createAlert, getAlert, listAlertsForUser, deleteAlert } from './alerts';
import { getSettings, updateSettings } from './settings';

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Users
app.post('/users', requireAuth, async (req, res) => res.json(await createUser(req.body)));
app.get('/users/:id', async (req, res) => res.json(await getUser(req.params.id)));
app.patch('/users/:id', requireAuth, async (req, res) => res.json(await updateUser(req.params.id, req.body)));
app.delete('/users/:id', requireAuth, async (req, res) => res.json(await deleteUser(req.params.id)));

// Profiles
app.post('/profiles', requireAuth, async (req, res) => res.json(await createProfile(req.body)));
app.get('/profiles/:id', async (req, res) => res.json(await getProfile(req.params.id)));
app.patch('/profiles/:id', requireAuth, async (req, res) => res.json(await updateProfile(req.params.id, req.body)));
app.delete('/profiles/:id', requireAuth, async (req, res) => res.json(await deleteProfile(req.params.id)));

// Contacts
app.post('/contacts', requireAuth, async (req, res) => res.json(await createContact(req.body)));
app.get('/contacts/:id', async (req, res) => res.json(await getContact(req.params.id)));
app.get('/contacts/user/:userId', async (req, res) => res.json(await listContactsForUser(req.params.userId)));
app.patch('/contacts/:id', requireAuth, async (req, res) => res.json(await updateContact(req.params.id, req.body)));
app.delete('/contacts/:id', requireAuth, async (req, res) => res.json(await deleteContact(req.params.id)));

// Alerts
app.post('/alerts', requireAuth, async (req, res) => res.json(await createAlert(req.body)));
app.get('/alerts/:id', async (req, res) => res.json(await getAlert(req.params.id)));
app.get('/alerts/user/:userId', async (req, res) => res.json(await listAlertsForUser(req.params.userId)));
app.delete('/alerts/:id', requireAuth, async (req, res) => res.json(await deleteAlert(req.params.id)));

// Settings
app.get('/settings/:userId', async (req, res) => res.json(await getSettings(req.params.userId)));
app.patch('/settings/:userId', requireAuth, async (req, res) => res.json(await updateSettings(req.params.userId, req.body)));

export const api = functions.https.onRequest(app);

