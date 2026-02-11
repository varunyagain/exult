import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/data/repositories/firebase_loan_repository.dart';
import 'package:exult_flutter/data/repositories/firebase_subscription_repository.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/domain/models/subscription_model.dart';
import 'package:exult_flutter/domain/repositories/loan_repository.dart';
import 'package:exult_flutter/domain/repositories/subscription_repository.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';

/// Provider for loan repository
final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return FirebaseLoanRepository();
});

/// Provider for subscription repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return FirebaseSubscriptionRepository();
});

/// Provider for current user's active subscription
final activeSubscriptionProvider = StreamProvider<Subscription?>((ref) {
  final authState = ref.watch(authStateProvider);
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);

  final user = authState.valueOrNull;
  if (user == null) {
    return Stream.value(null);
  }

  return subscriptionRepository.watchActiveSubscription(user.uid);
});

/// Provider to check if user has active subscription
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  final subscription = ref.watch(activeSubscriptionProvider);
  return subscription.valueOrNull != null;
});

/// Provider to check if user can borrow more books
final canBorrowMoreProvider = Provider<bool>((ref) {
  final subscription = ref.watch(activeSubscriptionProvider).valueOrNull;
  if (subscription == null) return false;
  return subscription.canBorrowMore;
});

/// Provider for remaining books count
final remainingBooksProvider = Provider<int>((ref) {
  final subscription = ref.watch(activeSubscriptionProvider).valueOrNull;
  if (subscription == null) return 0;
  return subscription.remainingBooks;
});

/// Subscription controller for creating and managing subscriptions
class SubscriptionController extends StateNotifier<AsyncValue<void>> {
  final SubscriptionRepository _subscriptionRepository;
  final Ref _ref;

  SubscriptionController(this._subscriptionRepository, this._ref)
      : super(const AsyncValue.data(null));

  /// Create a new subscription (mock payment flow)
  Future<bool> createSubscription({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authState = _ref.read(authStateProvider);
      final user = authState.valueOrNull;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate end date
      final now = DateTime.now();
      final endDate = billingCycle == BillingCycle.monthly
          ? DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year + 1, now.month, now.day);

      // Create subscription
      final subscription = Subscription(
        id: '', // Will be set by repository
        userId: user.uid,
        tier: tier,
        status: SubscriptionStatus.active,
        billingCycle: billingCycle,
        monthlyAmount: tier.monthlyPrice,
        maxBooks: tier.maxBooks,
        currentBooksCount: 0,
        startDate: now,
        endDate: endDate,
      );

      await _subscriptionRepository.createSubscription(subscription);

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Cancel the current subscription
  Future<bool> cancelSubscription() async {
    state = const AsyncValue.loading();

    try {
      final subscription = _ref.read(activeSubscriptionProvider).valueOrNull;

      if (subscription == null) {
        throw Exception('No active subscription found');
      }

      await _subscriptionRepository.cancelSubscription(subscription.id);

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

/// Provider for subscription controller
final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, AsyncValue<void>>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionController(subscriptionRepository, ref);
});

/// Stream provider for current user's loans
final myLoansProvider = StreamProvider<List<Loan>>((ref) {
  final authState = ref.watch(authStateProvider);
  final loanRepository = ref.watch(loanRepositoryProvider);

  final user = authState.valueOrNull;
  if (user == null) {
    return Stream.value([]);
  }

  return loanRepository.watchUserLoans(user.uid);
});

/// Loan controller for borrow and return operations
class LoanController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LoanController(this._ref) : super(const AsyncValue.data(null));

  /// Borrow a book
  Future<bool> borrowBook(Book book) async {
    state = const AsyncValue.loading();

    try {
      final authState = _ref.read(authStateProvider);
      final user = authState.valueOrNull;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final subscription =
          _ref.read(activeSubscriptionProvider).valueOrNull;
      if (subscription == null) {
        throw Exception('No active subscription');
      }

      if (!subscription.canBorrowMore) {
        throw Exception('Borrowing limit reached');
      }

      if (book.status != BookStatus.available) {
        throw Exception('Book is not available');
      }

      final now = DateTime.now();
      final loan = Loan(
        id: '',
        bookId: book.id,
        borrowerId: user.uid,
        subscriptionId: subscription.id,
        status: LoanStatus.active,
        depositAmount: book.depositAmount,
        depositPaid: true,
        borrowedAt: now,
        dueDate: now.add(const Duration(days: 14)),
      );

      final loanRepository = _ref.read(loanRepositoryProvider);
      await loanRepository.createLoan(loan);

      final subscriptionRepository =
          _ref.read(subscriptionRepositoryProvider);
      await subscriptionRepository.incrementBooksCount(subscription.id);

      final newAvailable = book.availableCopies - 1;
      final updatedBook = book.copyWith(
        availableCopies: newAvailable,
        status:
            newAvailable <= 0 ? BookStatus.borrowed : BookStatus.available,
      );
      final bookRepository = _ref.read(bookRepositoryProvider);
      await bookRepository.updateBook(updatedBook);

      // Auto-remove from favorites (non-critical, no-op if not favorited)
      try {
        final userRepository = _ref.read(userRepositoryProvider);
        await userRepository.removeFavorite(user.uid, book.id);
      } catch (_) {
        // Ignore — arrayRemove is a no-op if bookId not in array
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Return a borrowed book
  Future<bool> returnBook(Loan loan) async {
    state = const AsyncValue.loading();

    try {
      final loanRepository = _ref.read(loanRepositoryProvider);
      await loanRepository.returnLoan(loan.id);

      final subscriptionRepository =
          _ref.read(subscriptionRepositoryProvider);
      await subscriptionRepository.decrementBooksCount(loan.subscriptionId);

      final bookRepository = _ref.read(bookRepositoryProvider);
      final book = await bookRepository.getBookById(loan.bookId);
      final updatedBook = book.copyWith(
        availableCopies: book.availableCopies + 1,
        status: BookStatus.available,
      );
      await bookRepository.updateBook(updatedBook);

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

/// Provider for loan controller
final loanControllerProvider =
    StateNotifierProvider<LoanController, AsyncValue<void>>((ref) {
  return LoanController(ref);
});
