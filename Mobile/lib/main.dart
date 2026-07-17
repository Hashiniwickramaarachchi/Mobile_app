import 'package:flutter/material.dart';
import 'app.dart';
import 'services/firebase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initFirebase();
    runApp(const SafeGuardApp());
  } catch (e, stack) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Startup Error:\n\n$e\n\n$stack",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}