import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Wraps signInWithEmailAndPassword to survive the known firebase_auth
  /// Pigeon bug: "type 'List<Object?>' is not a subtype of type
  /// 'PigeonUserDetails?'". The native sign-in succeeds; only the decode of
  /// the UserCredential fails, so currentUser is already populated.
  Future<User?> _signInSafely({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException {
      rethrow; // real auth errors must stay visible
    } on TypeError {
      final user = _auth.currentUser;
      if (user != null) return user;
      rethrow;
    }
  }

  /// Same fallback for account creation.
  Future<User?> _createUserSafely({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException {
      rethrow;
    } on TypeError {
      final user = _auth.currentUser;
      if (user != null) return user;
      rethrow;
    }
  }

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
    final user = await _createUserSafely(
      email: email.trim(),
      password: password,
    );
    if (user == null) {
      throw Exception('Account creation failed');
    }

    // Save profile (username → email mapping) in Firestore
    await _db.collection('users').doc(user.uid).set({
      'username': uname,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  // LOGIN: username + password
  Future<User?> signIn({
    required String username,
    required String password,
  }) async {
    final input = username.trim().toLowerCase();

    // Try as email first
    if (input.contains('@')) {
      return _signInSafely(email: input, password: password);
    }

    // Otherwise look up username
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: input)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Username not found');
    }

    final email = query.docs.first['email'] as String;
    return _signInSafely(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Future<String?> getIdToken() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return await u.getIdToken();
  }
}