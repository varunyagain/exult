import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/providers/subscription_provider.dart';

class MyLoansScreen extends ConsumerWidget {
  const MyLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Loans')),
            body: const Center(child: Text('Please sign in')),
          );
        }
        return _MyLoansBody();
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('My Loans')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('My Loans')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MyLoansBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(myLoansProvider);
    final remaining = ref.watch(remainingBooksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Loans'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.book, size: 18),
                label: Text('$remaining remaining'),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Returned'),
            ],
          ),
        ),
        body: loansAsync.when(
          data: (loans) {
            final activeLoans = loans
                .where((l) => l.status != LoanStatus.returned)
                .toList();
            final returnedLoans = loans
                .where((l) => l.status == LoanStatus.returned)
                .toList();

            return TabBarView(
              children: [
                _LoanList(
                  loans: activeLoans,
                  emptyMessage: 'No active loans',
                  emptySubMessage: 'Browse books to borrow one!',
                  emptyIcon: Icons.library_books_outlined,
                  showReturnButton: true,
                ),
                _LoanList(
                  loans: returnedLoans,
                  emptyMessage: 'No returned loans yet',
                  emptySubMessage:
                      'Returned books will appear here',
                  emptyIcon: Icons.history,
                  showReturnButton: false,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading loans: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoanList extends StatelessWidget {
  final List<Loan> loans;
  final String emptyMessage;
  final String emptySubMessage;
  final IconData emptyIcon;
  final bool showReturnButton;

  const _LoanList({
    required this.loans,
    required this.emptyMessage,
    required this.emptySubMessage,
    required this.emptyIcon,
    required this.showReturnButton,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 64,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loans.length,
      itemBuilder: (context, index) => _LoanCard(
        loan: loans[index],
        showReturnButton: showReturnButton,
      ),
    );
  }
}

class _LoanCard extends ConsumerWidget {
  final Loan loan;
  final bool showReturnButton;

  const _LoanCard({
    required this.loan,
    required this.showReturnButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookByIdProvider(loan.bookId));
    final dateFormat = DateFormat.yMMMd();
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book title and status row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: bookAsync.when(
                    data: (book) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => context.go(
                              '${RouteConstants.books}/${book.id}'),
                          child: Text(
                            book.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${book.author}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        ),
                      ],
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Unknown book'),
                  ),
                ),
                _buildStatusChip(context),
              ],
            ),
            const Divider(height: 24),

            // Loan details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Borrowed',
                    value: dateFormat.format(loan.borrowedAt),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: loan.isReturned
                        ? Icons.check_circle
                        : Icons.event,
                    label: loan.isReturned ? 'Returned' : 'Due Date',
                    value: loan.isReturned && loan.returnedAt != null
                        ? dateFormat.format(loan.returnedAt!)
                        : dateFormat.format(loan.dueDate),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    label: 'Deposit',
                    value: currencyFormat.format(loan.depositAmount),
                  ),
                ),
              ],
            ),

            // Days remaining/overdue for active loans
            if (!loan.isReturned) ...[
              const SizedBox(height: 12),
              _buildDaysIndicator(context),
            ],

            // Return button
            if (showReturnButton && !loan.isReturned) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _handleReturnBook(context, ref, loan, bookAsync),
                  icon: const Icon(Icons.assignment_return),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Return Book'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String label;

    if (loan.isReturned) {
      chipColor = Colors.grey;
      label = 'Returned';
    } else if (loan.isOverdue) {
      chipColor = Colors.red;
      label = 'Overdue';
    } else {
      chipColor = Theme.of(context).colorScheme.primary;
      label = 'Active';
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysIndicator(BuildContext context) {
    if (loan.isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 18, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(
              '${loan.daysOverdue} day${loan.daysOverdue == 1 ? '' : 's'} overdue',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '${loan.daysRemaining} day${loan.daysRemaining == 1 ? '' : 's'} remaining',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleReturnBook(
    BuildContext context,
    WidgetRef ref,
    Loan loan,
    AsyncValue<Book> bookAsync,
  ) {
    final bookTitle =
        bookAsync.valueOrNull?.title ?? 'this book';

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
              'Are you sure you want to return \'$bookTitle\'?\n\n'
              'Your deposit will be refunded.',
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
                        final success = await ref
                            .read(loanControllerProvider.notifier)
                            .returnBook(loan);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '\'$bookTitle\' returned successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to return book. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
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
}
