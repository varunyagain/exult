import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/app.dart';
import 'package:exult_flutter/data/seed_data.dart';

// 1. Read the secrets from the environment
const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const String appId = String.fromEnvironment('FIREBASE_APP_ID');
const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain, 
      storageBucket: storageBucket,
    ),
  );

  runApp(const MyApp());
}