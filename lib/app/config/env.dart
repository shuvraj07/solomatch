/// Compile-time configuration, supplied with `--dart-define`.
///
/// Example (Android emulator talking to the local Firebase Emulator Suite):
/// ```sh
/// flutter run --dart-define=USE_FIREBASE_EMULATORS=true
/// ```
abstract final class Env {
  /// Route Auth, Firestore, Functions and Storage to the local emulators.
  static const useFirebaseEmulators = bool.fromEnvironment(
    'USE_FIREBASE_EMULATORS',
  );

  /// Host running the emulators. `10.0.2.2` is the host machine as seen from
  /// the Android emulator; use your LAN IP for a physical device.
  static const emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );

  /// Region the Cloud Functions are deployed to.
  static const functionsRegion = String.fromEnvironment(
    'FUNCTIONS_REGION',
    defaultValue: 'asia-south1',
  );
}
