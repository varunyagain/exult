import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersWithDetails = ref.watch(usersWithDetailsProvider);
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
        title: const Text('User Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.books),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(usersWithDetailsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RouteConstants.home);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: usersWithDetails.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No users found'),
                ],
              ),
            );
          }

          // Separate active subscribers and inactive users
          final activeSubscribers =
              users.where((u) => u.hasActiveSubscription).toList();
          final inactiveUsers =
              users.where((u) => !u.hasActiveSubscription).toList();

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(context, users),
                      const SizedBox(height: 32),

                      // Active Subscribers Section
                      if (activeSubscribers.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Active Subscribers',
                          activeSubscribers.length,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildUsersList(context, activeSubscribers),
                        const SizedBox(height: 32),
                      ],

                      // Inactive Users Section
                      if (inactiveUsers.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Inactive Users',
                          inactiveUsers.length,
                          Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        _buildUsersList(context, inactiveUsers),
                      ],
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(usersWithDetailsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<UserWithDetails> users) {
    final totalUsers = users.length;
    final activeSubscribers = users.where((u) => u.hasActiveSubscription).length;
    final totalBorrowedBooks =
        users.fold<int>(0, (sum, u) => sum + u.activeLoanCount);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _SummaryCard(
          icon: Icons.people,
          label: 'Total Users',
          value: '$totalUsers',
          color: Theme.of(context).primaryColor,
        ),
        _SummaryCard(
          icon: Icons.card_membership,
          label: 'Active Subscribers',
          value: '$activeSubscribers',
          color: Colors.green,
        ),
        _SummaryCard(
          icon: Icons.book,
          label: 'Books Borrowed',
          value: '$totalBorrowedBooks',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList(BuildContext context, List<UserWithDetails> users) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final userDetails = users[index];
          return _UserListTile(userDetails: userDetails);
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final UserWithDetails userDetails;

  const _UserListTile({required this.userDetails});

  @override
  Widget build(BuildContext context) {
    final user = userDetails.user;
    final dateFormat = DateFormat('MMM d, yyyy');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: userDetails.hasActiveSubscription
            ? Colors.green.shade100
            : Colors.grey.shade200,
        child: Text(
          user.displayName.isNotEmpty
              ? user.displayName[0].toUpperCase()
              : user.email[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: userDetails.hasActiveSubscription
                ? Colors.green.shade700
                : Colors.grey.shade700,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.displayName.isNotEmpty ? user.displayName : 'No Name',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (user.isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(user.email),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusChip(
                label: userDetails.subscriptionStatus,
                isActive: userDetails.hasActiveSubscription,
              ),
              const SizedBox(width: 8),
              if (userDetails.hasActiveSubscription) ...[
                Icon(Icons.book, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${userDetails.activeLoanCount} borrowed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Icon(Icons.inventory_2, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${userDetails.remainingCapacity} remaining',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          if (userDetails.subscription != null) ...[
            const SizedBox(height: 4),
            Text(
              '${userDetails.subscription!.tier.displayName} plan',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.go('${RouteConstants.admin}/users/${user.uid}');
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusChip({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
