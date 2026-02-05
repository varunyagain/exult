import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';
import 'package:exult_flutter/domain/models/subscription_model.dart';
import 'package:exult_flutter/domain/repositories/subscription_repository.dart';

class FirebaseSubscriptionRepository implements SubscriptionRepository {
  final FirebaseFirestore _firestore;

  FirebaseSubscriptionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConstants.subscriptionsCollection);

  @override
  Future<Subscription?> getActiveSubscription(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    final subscription = Subscription.fromJson({...doc.data(), 'id': doc.id});

    // Check if subscription has expired
    if (subscription.isExpired) {
      // Update status to expired
      await _collection.doc(doc.id).update({'status': 'expired'});
      return null;
    }

    return subscription;
  }

  @override
  Stream<Subscription?> watchActiveSubscription(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final subscription = Subscription.fromJson({...doc.data(), 'id': doc.id});

      // Return null if expired (will be updated on next read)
      if (subscription.isExpired) {
        return null;
      }

      return subscription;
    });
  }

  @override
  Future<List<Subscription>> getUserSubscriptions(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Subscription.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(String subscriptionId) async {
    final doc = await _collection.doc(subscriptionId).get();

    if (!doc.exists) {
      return null;
    }

    return Subscription.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<Subscription> createSubscription(Subscription subscription) async {
    // First, cancel any existing active subscriptions for this user
    final existingActive = await getActiveSubscription(subscription.userId);
    if (existingActive != null) {
      await cancelSubscription(existingActive.id);
    }

    final docRef = _collection.doc();
    final subscriptionWithId = subscription.copyWith(id: docRef.id);

    await docRef.set(subscriptionWithId.toJson());

    return subscriptionWithId;
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _collection.doc(subscription.id).update(subscription.toJson());
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    await _collection.doc(subscriptionId).update({
      'status': 'cancelled',
    });
  }

  @override
  Future<void> incrementBooksCount(String subscriptionId) async {
    await _collection.doc(subscriptionId).update({
      'currentBooksCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> decrementBooksCount(String subscriptionId) async {
    await _collection.doc(subscriptionId).update({
      'currentBooksCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<bool> hasActiveSubscription(String userId) async {
    final subscription = await getActiveSubscription(userId);
    return subscription != null;
  }
}
