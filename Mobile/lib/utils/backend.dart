class BackendConfig {
  // Override at build time with --dart-define=API_BASE=https://... or emulator URL
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://us-central1-your-project.cloudfunctions.net/api',
  );
}

class EmulatorConfig {
  static const useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  static const host =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');
  static const firestorePort =
      int.fromEnvironment('EMULATOR_FIRESTORE_PORT', defaultValue: 8081);
  static const authPort =
      int.fromEnvironment('EMULATOR_AUTH_PORT', defaultValue: 9099);
  static const functionsPort =
      int.fromEnvironment('EMULATOR_FUNCTIONS_PORT', defaultValue: 5001);
}
