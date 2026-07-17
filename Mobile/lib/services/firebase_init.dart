import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
import '../utils/backend.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (EmulatorConfig.useEmulator) {
    final host = EmulatorConfig.host;

    FirebaseAuth.instance.useAuthEmulator(
      host,
      EmulatorConfig.authPort,
    );

    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      EmulatorConfig.firestorePort,
    );
  }
}