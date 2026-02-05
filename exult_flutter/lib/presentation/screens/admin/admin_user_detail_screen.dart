import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
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
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.admin),
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
          final dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');

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
                                return _LoanTile(
                                  loan: activeLoans[index],
                                  ref: ref,
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
}

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

  const _LoanTile({
    required this.loan,
    required this.ref,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(loan.bookId));
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
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
      trailing: _buildStatusBadge(context),
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
