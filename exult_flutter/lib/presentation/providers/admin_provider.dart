import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/data/repositories/firebase_loan_repository.dart';
import 'package:exult_flutter/data/repositories/firebase_subscription_repository.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/domain/models/subscription_model.dart';
import 'package:exult_flutter/domain/models/user_model.dart';
import 'package:exult_flutter/domain/repositories/loan_repository.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/providers/subscription_provider.dart';

/// Provider for loan repository
final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return FirebaseLoanRepository();
});

/// Provider for all users stream (admin only)
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.watchAllUsers();
});

/// Provider for all loans stream (admin only)
final allLoansProvider = StreamProvider<List<Loan>>((ref) {
  final loanRepository = ref.watch(loanRepositoryProvider);
  return loanRepository.watchAllLoans();
});

/// Provider for user's subscription by userId
final userSubscriptionProvider =
    FutureProvider.family<Subscription?, String>((ref, userId) async {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  return subscriptionRepository.getActiveSubscription(userId);
});

/// Provider for user's loans by userId
final userLoansProvider =
    StreamProvider.family<List<Loan>, String>((ref, userId) {
  final loanRepository = ref.watch(loanRepositoryProvider);
  return loanRepository.watchUserLoans(userId);
});

/// Provider for user's active loans by userId
final userActiveLoansProvider =
    StreamProvider.family<List<Loan>, String>((ref, userId) {
  final loanRepository = ref.watch(loanRepositoryProvider);
  return loanRepository.watchActiveLoans(userId);
});

/// Combined user data with subscription and loan info for admin view
class UserWithDetails {
  final UserModel user;
  final Subscription? subscription;
  final int activeLoanCount;
  final int remainingCapacity;

  const UserWithDetails({
    required this.user,
    this.subscription,
    this.activeLoanCount = 0,
    this.remainingCapacity = 0,
  });

  bool get hasActiveSubscription => subscription?.isActive ?? false;
  String get subscriptionStatus =>
      hasActiveSubscription ? 'Active Subscriber' : 'Inactive';
}

/// Provider that combines user list with their subscription and loan data
final usersWithDetailsProvider =
    StreamProvider<List<UserWithDetails>>((ref) async* {
  final usersAsync = ref.watch(allUsersProvider);
  final loansAsync = ref.watch(allLoansProvider);
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);

  // Wait for users to load
  final users = usersAsync.valueOrNull ?? [];
  final allLoans = loansAsync.valueOrNull ?? [];

  if (users.isEmpty) {
    yield [];
    return;
  }

  // Build user details list
  final List<UserWithDetails> usersWithDetails = [];

  for (final user in users) {
    // Get active subscription for user
    Subscription? subscription;
    try {
      subscription = await subscriptionRepo.getActiveSubscription(user.uid);
    } catch (_) {
      subscription = null;
    }

    // Count active loans for this user
    final userActiveLoans = allLoans
        .where((loan) =>
            loan.borrowerId == user.uid && loan.status == LoanStatus.active)
        .length;

    // Calculate remaining capacity
    final maxBooks = subscription?.maxBooks ?? 0;
    final remaining = maxBooks - userActiveLoans;

    usersWithDetails.add(UserWithDetails(
      user: user,
      subscription: subscription,
      activeLoanCount: userActiveLoans,
      remainingCapacity: remaining > 0 ? remaining : 0,
    ));
  }

  yield usersWithDetails;
});

/// Provider for a single user's details by userId
final singleUserDetailsProvider =
    FutureProvider.family<UserWithDetails?, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final loanRepo = ref.watch(loanRepositoryProvider);

  final user = await userRepository.getUserById(userId);
  if (user == null) return null;

  Subscription? subscription;
  try {
    subscription = await subscriptionRepo.getActiveSubscription(userId);
  } catch (_) {
    subscription = null;
  }

  final activeLoanCount = await loanRepo.getActiveLoanCount(userId);
  final maxBooks = subscription?.maxBooks ?? 0;
  final remaining = maxBooks - activeLoanCount;

  return UserWithDetails(
    user: user,
    subscription: subscription,
    activeLoanCount: activeLoanCount,
    remainingCapacity: remaining > 0 ? remaining : 0,
  );
});

/// Provider to get book details for loans
final loanWithBookProvider =
    FutureProvider.family<LoanWithBook?, Loan>((ref, loan) async {
  final bookRepository = ref.watch(bookRepositoryProvider);

  try {
    final book = await bookRepository.getBookById(loan.bookId);
    return LoanWithBook(loan: loan, book: book);
  } catch (_) {
    return LoanWithBook(loan: loan, book: null);
  }
});

/// Combined loan and book data
class LoanWithBook {
  final Loan loan;
  final Book? book;

  const LoanWithBook({
    required this.loan,
    this.book,
  });
}

/// Check if current user is admin
final isAdminProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.valueOrNull?.isAdmin ?? false;
});

/// Date range for dashboard filtering
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  DateRange get previousPeriod {
    final duration = end.difference(start);
    return DateRange(
      start: start.subtract(duration),
      end: start,
    );
  }
}

/// Dashboard metrics computed from existing data
class DashboardMetrics {
  final int totalBooksLent;
  final int previousBooksLent;
  final int totalBooksUnderManagement;
  final int previousBooksUnderManagement;
  final int totalActiveSubscribers;
  final int previousActiveSubscribers;

  const DashboardMetrics({
    required this.totalBooksLent,
    required this.previousBooksLent,
    required this.totalBooksUnderManagement,
    required this.previousBooksUnderManagement,
    required this.totalActiveSubscribers,
    required this.previousActiveSubscribers,
  });

  double get booksLentChange => _percentChange(previousBooksLent, totalBooksLent);
  double get booksManagementChange =>
      _percentChange(previousBooksUnderManagement, totalBooksUnderManagement);
  double get subscribersChange =>
      _percentChange(previousActiveSubscribers, totalActiveSubscribers);

  double _percentChange(int previous, int current) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }
}

/// Provider for the selected date range
final dashboardDateRangeProvider = StateProvider<DateRange>((ref) {
  final now = DateTime.now();
  return DateRange(
    start: DateTime(now.year, now.month, 1),
    end: now,
  );
});

/// Provider that computes dashboard metrics from existing streams
final dashboardMetricsProvider = Provider<AsyncValue<DashboardMetrics>>((ref) {
  final dateRange = ref.watch(dashboardDateRangeProvider);
  final loansAsync = ref.watch(allLoansProvider);
  final booksAsync = ref.watch(allBooksProvider);
  final usersAsync = ref.watch(allUsersProvider);

  // Check if all data is loaded
  if (loansAsync.isLoading || booksAsync.isLoading || usersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (loansAsync.hasError) return AsyncValue.error(loansAsync.error!, loansAsync.stackTrace!);
  if (booksAsync.hasError) return AsyncValue.error(booksAsync.error!, booksAsync.stackTrace!);
  if (usersAsync.hasError) return AsyncValue.error(usersAsync.error!, usersAsync.stackTrace!);

  final loans = loansAsync.value ?? [];
  final books = booksAsync.value ?? [];
  final users = usersAsync.value ?? [];

  final previousRange = dateRange.previousPeriod;

  // (a) Total Books Lent — loans where borrowedAt falls in period
  final currentLoans = loans
      .where((l) =>
          l.borrowedAt.isAfter(dateRange.start) &&
          l.borrowedAt.isBefore(dateRange.end))
      .length;
  final previousLoans = loans
      .where((l) =>
          l.borrowedAt.isAfter(previousRange.start) &&
          l.borrowedAt.isBefore(previousRange.end))
      .length;

  // (b) Total Books Under Management — sum of totalCopies for books existing by end of period
  final currentBooks = books
      .where((b) => b.createdAt.isBefore(dateRange.end))
      .fold<int>(0, (sum, b) => sum + b.totalCopies);
  final previousBooks = books
      .where((b) => b.createdAt.isBefore(previousRange.end))
      .fold<int>(0, (sum, b) => sum + b.totalCopies);

  // (c) Total Subscribers — users created by end of period (proxy for active subscribers)
  final currentSubscribers = users
      .where((u) => u.createdAt.isBefore(dateRange.end) && u.role == UserRole.subscriber)
      .length;
  final previousSubscribers = users
      .where((u) => u.createdAt.isBefore(previousRange.end) && u.role == UserRole.subscriber)
      .length;

  return AsyncValue.data(DashboardMetrics(
    totalBooksLent: currentLoans,
    previousBooksLent: previousLoans,
    totalBooksUnderManagement: currentBooks,
    previousBooksUnderManagement: previousBooks,
    totalActiveSubscribers: currentSubscribers,
    previousActiveSubscribers: previousSubscribers,
  ));
});
