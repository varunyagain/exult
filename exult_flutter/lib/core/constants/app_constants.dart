/// Application-wide constants including subscription tiers and pricing
class AppConstants {
  // App info
  static const String appName = 'Exult';
  static const String appTagline = 'Borrow books through subscriptions or lend your own securely';

  // Subscription pricing (INR)
  static const double oneBookMonthly = 99.0;
  static const double threeBookMonthly = 199.0;
  static const double fiveBookMonthly = 299.0;

  static const double oneBookAnnual = 999.0;
  static const double threeBookAnnual = 1999.0;
  static const double fiveBookAnnual = 2999.0;

  // Subscription limits
  static const int oneBookLimit = 1;
  static const int threeBookLimit = 3;
  static const int fiveBookLimit = 5;

  // Default deposit amount for books
  static const double defaultDepositAmount = 200.0;

  // Loan duration (days)
  static const int defaultLoanDurationDays = 14;

  // Pagination
  static const int booksPerPage = 12;
  static const int loansPerPage = 10;

  // Contact info
  static const String contactEmail = 'hello@exultbooks.in';
  static const String contactPhone = '+91 98765 43210';
}

/// Subscription tier enums
enum SubscriptionTier {
  oneBook,
  threeBooks,
  fiveBooks;

  String get displayName {
    switch (this) {
      case SubscriptionTier.oneBook:
        return 'One Book';
      case SubscriptionTier.threeBooks:
        return 'Three Books';
      case SubscriptionTier.fiveBooks:
        return 'Five Books';
    }
  }

  int get maxBooks {
    switch (this) {
      case SubscriptionTier.oneBook:
        return AppConstants.oneBookLimit;
      case SubscriptionTier.threeBooks:
        return AppConstants.threeBookLimit;
      case SubscriptionTier.fiveBooks:
        return AppConstants.fiveBookLimit;
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.oneBook:
        return AppConstants.oneBookMonthly;
      case SubscriptionTier.threeBooks:
        return AppConstants.threeBookMonthly;
      case SubscriptionTier.fiveBooks:
        return AppConstants.fiveBookMonthly;
    }
  }

  double get annualPrice {
    switch (this) {
      case SubscriptionTier.oneBook:
        return AppConstants.oneBookAnnual;
      case SubscriptionTier.threeBooks:
        return AppConstants.threeBookAnnual;
      case SubscriptionTier.fiveBooks:
        return AppConstants.fiveBookAnnual;
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.oneBook:
        return 'Perfect for casual readers';
      case SubscriptionTier.threeBooks:
        return 'Best for regular readers';
      case SubscriptionTier.fiveBooks:
        return 'Ideal for avid book lovers';
    }
  }
}

/// Billing cycle options
enum BillingCycle {
  monthly,
  annual;

  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.annual:
        return 'Annual';
    }
  }
}
