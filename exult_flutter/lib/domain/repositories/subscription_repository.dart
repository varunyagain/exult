import 'package:exult_flutter/domain/models/subscription_model.dart';

/// Abstract repository interface for subscription operations
abstract class SubscriptionRepository {
  /// Get the active subscription for a user
  Future<Subscription?> getActiveSubscription(String userId);

  /// Get a stream of the user's active subscription
  Stream<Subscription?> watchActiveSubscription(String userId);

  /// Get all subscriptions for a user (including expired/cancelled)
  Future<List<Subscription>> getUserSubscriptions(String userId);

  /// Get a specific subscription by ID
  Future<Subscription?> getSubscriptionById(String subscriptionId);

  /// Create a new subscription
  Future<Subscription> createSubscription(Subscription subscription);

  /// Update an existing subscription
  Future<void> updateSubscription(Subscription subscription);

  /// Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId);

  /// Increment the current books count for a subscription
  Future<void> incrementBooksCount(String subscriptionId);

  /// Decrement the current books count for a subscription
  Future<void> decrementBooksCount(String subscriptionId);

  /// Check if user has an active subscription
  Future<bool> hasActiveSubscription(String userId);
}
