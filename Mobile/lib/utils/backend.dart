class BackendConfig {
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue:
        'https://us-central1-safeguard-aab9a.cloudfunctions.net/api',
  );
}

class EmulatorConfig {
  static const bool useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  static const String host =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');

  static const int firestorePort =
      int.fromEnvironment('EMULATOR_FIRESTORE_PORT', defaultValue: 8081);

  static const int authPort =
      int.fromEnvironment('EMULATOR_AUTH_PORT', defaultValue: 9099);

  static const int functionsPort =
      int.fromEnvironment('EMULATOR_FUNCTIONS_PORT', defaultValue: 5001);
}