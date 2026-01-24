import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:exult_flutter/domain/models/user_model.dart';

/// Abstract authentication repository interface
abstract class AuthRepository {
  /// Get the current Firebase auth user
  firebase_auth.User? get currentUser;

  /// Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register new user with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Check if user is authenticated
  bool get isAuthenticated;
}
