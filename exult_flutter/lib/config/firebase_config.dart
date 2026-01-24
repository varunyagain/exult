/// Firebase configuration
///
/// To set up Firebase:
/// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
/// 2. Run: flutterfire configure
/// 3. Select your Firebase project (or create a new one)
/// 4. This will generate lib/firebase_options.dart with your configuration
///
/// The firebase_options.dart file is generated automatically and should not be
/// committed to version control if it contains sensitive information.
///
/// For local development, you can use the Firebase Emulator Suite:
/// - firebase emulators:start
///
/// Note: This file is a placeholder. The actual configuration will be in
/// firebase_options.dart after running flutterfire configure.

class FirebaseConfig {
  static const bool useEmulator = false; // Set to true for local development
  static const String emulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
}
