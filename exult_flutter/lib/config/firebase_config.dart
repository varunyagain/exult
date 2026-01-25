/// Firebase configuration
///
/// To set up Firebase:
/// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
/// 2. Run: flutterfire configure
/// 3. Select your Firebase project (or create a new one)
/// 4. This will generate lib/firebase_options.dart with your configuration
///
/// Alternatively, you can copy lib/firebase_options.dart.template to
/// lib/firebase_options.dart and fill in your Firebase project credentials.
///
/// IMPORTANT: The firebase_options.dart file contains sensitive API keys and
/// is excluded from version control via .gitignore. Never commit this file!
///
/// For local development, you can use the Firebase Emulator Suite:
/// - firebase emulators:start
///
/// Note: See firebase_options.dart.template for the expected file structure.

class FirebaseConfig {
  static const bool useEmulator = false; // Set to true for local development
  static const String emulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
}
