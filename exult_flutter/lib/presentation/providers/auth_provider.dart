import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/data/repositories/firebase_auth_repository.dart';
import 'package:exult_flutter/data/repositories/firebase_user_repository.dart';
import 'package:exult_flutter/domain/models/user_model.dart';
import 'package:exult_flutter/domain/repositories/auth_repository.dart';
import 'package:exult_flutter/domain/repositories/user_repository.dart';

/// Provider for user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

/// Provider for auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return FirebaseAuthRepository(userRepository: userRepository);
});

/// Provider for Firebase auth user stream
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for current user model
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  await for (final firebaseUser in authState.whenData((user) async* {
    yield user;
  }).value ?? Stream.value(null)) {
    if (firebaseUser == null) {
      yield null;
    } else {
      final userModel = await userRepository.getUserById(firebaseUser.uid);
      yield userModel;
    }
  }
});

/// Auth controller for sign in, sign up, and sign out operations
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for auth controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});
