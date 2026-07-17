import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // SIGNUP: email + username + password
  Future<User?> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    final uname = username.trim().toLowerCase();

    // Username must be unique
    final existing = await _db
        .collection('users')
        .where('username', isEqualTo: uname)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Username already taken');
    }

    // Create Auth account with email
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Save profile (username → email mapping) in Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'username': uname,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred.user;
  }

  // LOGIN: username + password
  Future<User?> signIn({
    required String username,
    required String password,
  }) async {
    final uname = username.trim().toLowerCase();

    // Look up email for this username
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: uname)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Username not found');
    }
    final email = query.docs.first['email'] as String;

    // Sign in with the mapped email
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Future<String?> getIdToken() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return await u.getIdToken();
  }
}