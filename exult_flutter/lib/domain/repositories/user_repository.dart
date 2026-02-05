import 'package:exult_flutter/domain/models/user_model.dart';

/// Abstract user repository interface
abstract class UserRepository {
  /// Get user by ID
  Future<UserModel?> getUserById(String userId);

  /// Create new user
  Future<void> createUser(UserModel user);

  /// Update existing user
  Future<void> updateUser(UserModel user);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Stream of user data
  Stream<UserModel?> watchUser(String userId);

  /// Get all users (admin only)
  Future<List<UserModel>> getAllUsers();

  /// Stream of all users (admin only)
  Stream<List<UserModel>> watchAllUsers();

  /// Check if user exists
  Future<bool> userExists(String userId);
}
