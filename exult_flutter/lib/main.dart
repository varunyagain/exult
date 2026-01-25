import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/app.dart';
import 'package:exult_flutter/data/seed_data.dart';
import 'firebase_options.dart';

/// Main entry point for the Exult application
///
/// Before running the app, ensure Firebase is configured:
/// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
/// 2. Run: flutterfire configure
/// 3. Select your Firebase project
/// 4. This will generate firebase_options.dart
///
/// Once configured, you can run the app with:
/// flutter run -d chrome (for web)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed sample books if database is empty (runs only once)
  // Wrapped in try-catch to not block app startup
  try {
    await SeedData.seedBooks();
  } catch (e) {
    print('Seeding skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: ExultApp(),
    ),
  );
}
