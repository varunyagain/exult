import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/domain/models/subscription_model.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/providers/subscription_provider.dart';
import 'package:intl/intl.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  final String userId;

  const AdminUserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailsAsync = ref.watch(singleUserDetailsProvider(userId));
    final userLoansAsync = ref.watch(userLoansProvider(userId));
    final isAdmin = ref.watch(isAdminProvider);

    // Redirect non-admins
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.books);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.adminSubscribers),
        ),
      ),
      body: userDetailsAsync.when(
        data: (userDetails) {
          if (userDetails == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('User not found'),
                ],
              ),
            );
          }

          final user = userDetails.user;
          final subscription = userDetails.subscription;
          final dateFormat = DateFormat('MMM d, yyyy');

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Header Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: userDetails.hasActiveSubscription
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : user.email[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: userDetails.hasActiveSubscription
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.displayName.isNotEmpty
                                                ? user.displayName
                                                : 'No Name',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        if (user.isAdmin)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Admin',
                                              style: TextStyle(
                                                color: Colors.purple.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    if (user.phoneNumber != null &&
                                        user.phoneNumber!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 16),
                                          const SizedBox(width: 4),
                                          Text(user.phoneNumber!),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      'Member since ${dateFormat.format(user.createdAt)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.card_membership,
                              label: 'Subscription',
                              value: userDetails.hasActiveSubscription
                                  ? subscription!.tier.displayName
                                  : 'Inactive',
                              color: userDetails.hasActiveSubscription
                                  ? Colors.green
                                  : Colors.grey,
                              subtitle: userDetails.hasActiveSubscription
                                  ? 'Expires ${dateFormat.format(subscription!.endDate)}'
                                  : 'No active subscription',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.book,
                              label: 'Books Borrowed',
                              value: '${userDetails.activeLoanCount}',
                              color: Colors.blue,
                              subtitle: userDetails.hasActiveSubscription
                                  ? 'of ${subscription!.maxBooks} max'
                                  : 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.inventory_2,
                              label: 'Remaining',
                              value: '${userDetails.remainingCapacity}',
                              color: userDetails.remainingCapacity > 0
                                  ? Colors.orange
                                  : Colors.red,
                              subtitle: userDetails.remainingCapacity > 0
                                  ? 'books available to borrow'
                                  : 'at limit',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Subscription Actions Section
                      _buildSectionTitle(context, 'Subscription Actions'),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userDetails.hasActiveSubscription) ...[
                                Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${subscription!.tier.displayName} plan \u2022 ${subscription.billingCycle.displayName}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _showEditSubscriptionDialog(
                                              context, ref, subscription),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit Plan'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showCancelSubscriptionDialog(
                                              context, ref, subscription.id),
                                      icon: const Icon(Icons.cancel,
                                          size: 18, color: Colors.red),
                                      label: const Text('Cancel Subscription',
                                          style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                                if (userDetails.remainingCapacity > 0) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          _showBorrowBookDialog(
                                              context, ref, userDetails),
                                      icon: const Icon(Icons.library_add),
                                      label: const Text(
                                          'Borrow a Book for This User'),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.grey.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                          'No active subscription for this user.'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () =>
                                      _showCreateSubscriptionDialog(
                                          context, ref),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Create Subscription'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Address Section
                      _buildSectionTitle(context, 'Address'),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: user.address != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user.address!.street.isNotEmpty)
                                      _AddressRow(
                                        icon: Icons.location_on,
                                        label: 'Street',
                                        value: user.address!.street,
                                      ),
                                    if (user.address!.city.isNotEmpty)
                                      _AddressRow(
                                        icon: Icons.location_city,
                                        label: 'City',
                                        value: user.address!.city,
                                      ),
                                    if (user.address!.pincode.isNotEmpty)
                                      _AddressRow(
                                        icon: Icons.pin_drop,
                                        label: 'Pincode',
                                        value: user.address!.pincode,
                                      ),
                                    if (user.address!.street.isEmpty &&
                                        user.address!.city.isEmpty &&
                                        user.address!.pincode.isEmpty)
                                      const Text(
                                        'No address provided',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                )
                              : const Text(
                                  'No address provided',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Currently Borrowed Books
                      _buildSectionTitle(context, 'Currently Borrowed Books'),
                      const SizedBox(height: 12),
                      userLoansAsync.when(
                        data: (loans) {
                          final activeLoans = loans
                              .where((l) => l.status == LoanStatus.active)
                              .toList();

                          if (activeLoans.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.library_books_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No books currently borrowed',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activeLoans.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final loan = activeLoans[index];
                                return _LoanTile(
                                  loan: loan,
                                  ref: ref,
                                  onReturn: () => _showReturnBookDialog(
                                      context, ref, loan),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (_, __) => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Error loading loans'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Loan History
                      _buildSectionTitle(context, 'Loan History'),
                      const SizedBox(height: 12),
                      userLoansAsync.when(
                        data: (loans) {
                          final pastLoans = loans
                              .where((l) => l.status != LoanStatus.active)
                              .toList();

                          if (pastLoans.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No loan history',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pastLoans.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _LoanTile(
                                  loan: pastLoans[index],
                                  ref: ref,
                                  isPast: true,
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (_, __) => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Error loading loan history'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // --- Subscription action handlers ---

  void _showCreateSubscriptionDialog(BuildContext context, WidgetRef ref) {
    showDialog<Subscription>(
      context: context,
      builder: (dialogContext) => _SubscriptionFormDialog(userId: userId),
    ).then((result) async {
      if (result == null) return;
      try {
        final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
        await subscriptionRepo.createSubscription(result);
        ref.invalidate(singleUserDetailsProvider(userId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create subscription: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _showEditSubscriptionDialog(
      BuildContext context, WidgetRef ref, Subscription subscription) {
    showDialog<Subscription>(
      context: context,
      builder: (dialogContext) => _SubscriptionFormDialog(
        userId: userId,
        subscription: subscription,
      ),
    ).then((result) async {
      if (result == null) return;
      try {
        final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
        await subscriptionRepo.updateSubscription(result);
        ref.invalidate(singleUserDetailsProvider(userId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update subscription: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _showCancelSubscriptionDialog(
      BuildContext context, WidgetRef ref, String subscriptionId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        var isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 8),
                Text('Cancel Subscription'),
              ],
            ),
            content: const Text(
              'Are you sure you want to cancel this subscription?\n\n'
              'The user will no longer be able to borrow books.',
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Keep Subscription'),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          final subscriptionRepo =
                              ref.read(subscriptionRepositoryProvider);
                          await subscriptionRepo
                              .cancelSubscription(subscriptionId);
                          ref.invalidate(singleUserDetailsProvider(userId));
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Subscription cancelled successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to cancel subscription: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Cancel Subscription'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Loan action handlers ---

  void _showReturnBookDialog(
      BuildContext context, WidgetRef ref, Loan loan) {
    final bookAsync = ref.read(bookByIdProvider(loan.bookId));
    final bookTitle = bookAsync.valueOrNull?.title ?? 'this book';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.assignment_return),
                SizedBox(width: 8),
                Text('Return Book'),
              ],
            ),
            content: Text(
              'Are you sure you want to return \'$bookTitle\' on behalf of this user?\n\n'
              'Their deposit will be refunded.',
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          final loanRepo = ref.read(loanRepositoryProvider);
                          final subscriptionRepo =
                              ref.read(subscriptionRepositoryProvider);
                          final bookRepo = ref.read(bookRepositoryProvider);

                          await loanRepo.returnLoan(loan.id);
                          await subscriptionRepo
                              .decrementBooksCount(loan.subscriptionId);

                          final book =
                              await bookRepo.getBookById(loan.bookId);
                          final updatedBook = book.copyWith(
                            availableCopies: book.availableCopies + 1,
                            status: BookStatus.available,
                          );
                          await bookRepo.updateBook(updatedBook);

                          ref.invalidate(
                              singleUserDetailsProvider(userId));
                          ref.invalidate(userLoansProvider(userId));
                          ref.invalidate(bookByIdProvider(loan.bookId));
                          ref.invalidate(availableBooksProvider);

                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '\'$bookTitle\' returned successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to return book: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Return'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBorrowBookDialog(
      BuildContext context, WidgetRef ref, UserWithDetails userDetails) {
    showDialog<Book>(
      context: context,
      builder: (dialogContext) => _BorrowBookDialog(ref: ref),
    ).then((selectedBook) async {
      if (selectedBook == null) return;
      final subscription = userDetails.subscription;
      if (subscription == null) return;

      try {
        final loanRepo = ref.read(loanRepositoryProvider);
        final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
        final bookRepo = ref.read(bookRepositoryProvider);

        final now = DateTime.now();
        final loan = Loan(
          id: '',
          bookId: selectedBook.id,
          borrowerId: userId,
          subscriptionId: subscription.id,
          status: LoanStatus.active,
          depositAmount: selectedBook.depositAmount,
          depositPaid: true,
          borrowedAt: now,
          dueDate: now.add(
              const Duration(days: AppConstants.defaultLoanDurationDays)),
        );

        await loanRepo.createLoan(loan);
        await subscriptionRepo.incrementBooksCount(subscription.id);

        final newAvailable = selectedBook.availableCopies - 1;
        final updatedBook = selectedBook.copyWith(
          availableCopies: newAvailable,
          status:
              newAvailable <= 0 ? BookStatus.borrowed : BookStatus.available,
        );
        await bookRepo.updateBook(updatedBook);

        ref.invalidate(singleUserDetailsProvider(userId));
        ref.invalidate(userLoansProvider(userId));
        ref.invalidate(bookByIdProvider(selectedBook.id));
        ref.invalidate(availableBooksProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '\'${selectedBook.title}\' borrowed for this user!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to borrow book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}

// --- Private widgets ---

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subtitle;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AddressRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  final Loan loan;
  final WidgetRef ref;
  final bool isPast;
  final VoidCallback? onReturn;

  const _LoanTile({
    required this.loan,
    required this.ref,
    this.isPast = false,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(loan.bookId));
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: bookAsync.when(
        data: (book) => Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    book.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.book),
                  ),
                )
              : const Icon(Icons.book),
        ),
        loading: () => Container(
          width: 50,
          height: 70,
          color: Colors.grey.shade200,
        ),
        error: (_, __) => Container(
          width: 50,
          height: 70,
          color: Colors.grey.shade200,
          child: const Icon(Icons.book),
        ),
      ),
      title: bookAsync.when(
        data: (book) => Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        loading: () => const Text('Loading...'),
        error: (_, __) => const Text('Unknown Book'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          bookAsync.when(
            data: (book) => Text('by ${book.author}'),
            loading: () => const Text(''),
            error: (_, __) => const Text(''),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Borrowed: ${dateFormat.format(loan.borrowedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPast ? Icons.check_circle : Icons.event,
                size: 14,
                color: isPast
                    ? Colors.green.shade600
                    : loan.isOverdue
                        ? Colors.red.shade600
                        : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                isPast
                    ? 'Returned: ${loan.returnedAt != null ? dateFormat.format(loan.returnedAt!) : 'N/A'}'
                    : 'Due: ${dateFormat.format(loan.dueDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: !isPast && loan.isOverdue ? Colors.red : null,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Deposit: ${currencyFormat.format(loan.depositAmount)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusBadge(context),
          if (onReturn != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.assignment_return),
              tooltip: 'Return Book',
              onPressed: onReturn,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String label;

    if (loan.status == LoanStatus.returned) {
      color = Colors.green;
      label = 'Returned';
    } else if (loan.isOverdue) {
      color = Colors.red;
      label = 'Overdue';
    } else {
      color = Colors.blue;
      label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Subscription Form Dialog ---

class _SubscriptionFormDialog extends StatefulWidget {
  final String userId;
  final Subscription? subscription;

  const _SubscriptionFormDialog({
    required this.userId,
    this.subscription,
  });

  @override
  State<_SubscriptionFormDialog> createState() =>
      _SubscriptionFormDialogState();
}

class _SubscriptionFormDialogState extends State<_SubscriptionFormDialog> {
  late SubscriptionTier _tier;
  late BillingCycle _billingCycle;
  late SubscriptionStatus _status;
  late DateTime _endDate;

  bool get isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _tier = widget.subscription!.tier;
      _billingCycle = widget.subscription!.billingCycle;
      _status = widget.subscription!.status;
      _endDate = widget.subscription!.endDate;
    } else {
      _tier = SubscriptionTier.oneBook;
      _billingCycle = BillingCycle.monthly;
      _status = SubscriptionStatus.active;
      _endDate = _calculateEndDate(BillingCycle.monthly);
    }
  }

  DateTime _calculateEndDate(BillingCycle cycle) {
    final now = DateTime.now();
    return cycle == BillingCycle.monthly
        ? DateTime(now.year, now.month + 1, now.day)
        : DateTime(now.year + 1, now.month, now.day);
  }

  double _getPrice() {
    return _billingCycle == BillingCycle.monthly
        ? _tier.monthlyPrice
        : _tier.annualPrice;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.card_membership),
          const SizedBox(width: 8),
          Text(isEditing ? 'Edit Subscription' : 'Create Subscription'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier dropdown
            DropdownButtonFormField<SubscriptionTier>(
              value: _tier,
              decoration: const InputDecoration(
                labelText: 'Tier',
                border: OutlineInputBorder(),
              ),
              items: SubscriptionTier.values.map((tier) {
                return DropdownMenuItem(
                  value: tier,
                  child: Text(
                      '${tier.displayName} (${tier.maxBooks} book${tier.maxBooks > 1 ? 's' : ''})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tier = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Billing cycle dropdown
            DropdownButtonFormField<BillingCycle>(
              value: _billingCycle,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
                border: OutlineInputBorder(),
              ),
              items: BillingCycle.values.map((cycle) {
                return DropdownMenuItem(
                  value: cycle,
                  child: Text(cycle.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _billingCycle = value;
                    if (!isEditing) {
                      _endDate = _calculateEndDate(value);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Status dropdown (edit mode only)
            if (isEditing) ...[
              DropdownButtonFormField<SubscriptionStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: SubscriptionStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // End date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) {
                  setState(() => _endDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(dateFormat.format(_endDate)),
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Books:'),
                      Text('${_tier.maxBooks}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount:'),
                      Text(currencyFormat.format(_getPrice()),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final now = DateTime.now();
            final subscription = isEditing
                ? widget.subscription!.copyWith(
                    tier: _tier,
                    billingCycle: _billingCycle,
                    status: _status,
                    monthlyAmount: _tier.monthlyPrice,
                    maxBooks: _tier.maxBooks,
                    endDate: _endDate,
                  )
                : Subscription(
                    id: '',
                    userId: widget.userId,
                    tier: _tier,
                    status: SubscriptionStatus.active,
                    billingCycle: _billingCycle,
                    monthlyAmount: _tier.monthlyPrice,
                    maxBooks: _tier.maxBooks,
                    currentBooksCount: 0,
                    startDate: now,
                    endDate: _endDate,
                  );
            Navigator.of(context).pop(subscription);
          },
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

// --- Borrow Book Dialog ---

class _BorrowBookDialog extends StatefulWidget {
  final WidgetRef ref;

  const _BorrowBookDialog({required this.ref});

  @override
  State<_BorrowBookDialog> createState() => _BorrowBookDialogState();
}

class _BorrowBookDialogState extends State<_BorrowBookDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final booksAsync = widget.ref.watch(availableBooksProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.library_add),
          SizedBox(width: 8),
          Text('Borrow a Book'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: booksAsync.when(
                data: (books) {
                  final availableBooks = books
                      .where((b) => b.availableCopies > 0)
                      .where((b) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return b.title.toLowerCase().contains(q) ||
                        b.author.toLowerCase().contains(q);
                  }).toList();

                  if (availableBooks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No books available'
                                : 'No books match your search',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: availableBooks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final book = availableBooks[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: book.coverImageUrl != null &&
                                  book.coverImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    book.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.book, size: 20),
                                  ),
                                )
                              : const Icon(Icons.book, size: 20),
                        ),
                        title: Text(
                          book.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${book.author} \u2022 Deposit: ${currencyFormat.format(book.depositAmount)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${book.availableCopies} avail.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => Navigator.of(context).pop(book),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('Error loading books'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
