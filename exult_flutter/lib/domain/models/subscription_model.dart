import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';

/// Subscription status
enum SubscriptionStatus {
  active,
  cancelled,
  expired;

  String toJson() => name;

  static SubscriptionStatus fromJson(String json) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => SubscriptionStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }
}

/// Subscription model representing a user's subscription
class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final double monthlyAmount;
  final int maxBooks;
  final int currentBooksCount;
  final DateTime startDate;
  final DateTime endDate;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.billingCycle,
    required this.monthlyAmount,
    required this.maxBooks,
    required this.currentBooksCount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.name,
      'status': status.toJson(),
      'billingCycle': billingCycle.name,
      'monthlyAmount': monthlyAmount,
      'maxBooks': maxBooks,
      'currentBooksCount': currentBooksCount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.oneBook,
      ),
      status: SubscriptionStatus.fromJson(json['status'] as String? ?? 'active'),
      billingCycle: BillingCycle.values.firstWhere(
        (c) => c.name == json['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      monthlyAmount: (json['monthlyAmount'] as num?)?.toDouble() ?? 0.0,
      maxBooks: json['maxBooks'] as int? ?? 1,
      currentBooksCount: json['currentBooksCount'] as int? ?? 0,
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    BillingCycle? billingCycle,
    double? monthlyAmount,
    int? maxBooks,
    int? currentBooksCount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      billingCycle: billingCycle ?? this.billingCycle,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      maxBooks: maxBooks ?? this.maxBooks,
      currentBooksCount: currentBooksCount ?? this.currentBooksCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isActive => status == SubscriptionStatus.active && endDate.isAfter(DateTime.now());
  bool get canBorrowMore => currentBooksCount < maxBooks;
  int get remainingBooks => maxBooks - currentBooksCount;
  bool get isExpired => endDate.isBefore(DateTime.now());
}
