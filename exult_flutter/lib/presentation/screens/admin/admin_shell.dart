import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Navigation items
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: RouteConstants.admin,
                  isSelected: currentLocation == RouteConstants.admin,
                  onTap: () => context.go(RouteConstants.admin),
                ),
                _NavItem(
                  icon: Icons.people,
                  label: 'Manage Subscribers',
                  route: RouteConstants.adminSubscribers,
                  isSelected:
                      currentLocation.startsWith(RouteConstants.adminSubscribers),
                  onTap: () => context.go(RouteConstants.adminSubscribers),
                ),
                _NavItem(
                  icon: Icons.library_books,
                  label: 'Manage Books',
                  route: RouteConstants.adminBooks,
                  isSelected: currentLocation == RouteConstants.adminBooks,
                  onTap: () => context.go(RouteConstants.adminBooks),
                ),
                _NavItem(
                  icon: Icons.attach_money,
                  label: 'Financials',
                  route: RouteConstants.adminFinancials,
                  isSelected:
                      currentLocation == RouteConstants.adminFinancials,
                  onTap: () => context.go(RouteConstants.adminFinancials),
                ),

                const Spacer(),

                // Browse Books link
                const Divider(height: 1),
                _NavItem(
                  icon: Icons.menu_book,
                  label: 'Browse Books',
                  route: RouteConstants.books,
                  isSelected: false,
                  onTap: () => context.go(RouteConstants.books),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  route: RouteConstants.profile,
                  isSelected: currentLocation == RouteConstants.profile,
                  onTap: () => context.go(RouteConstants.profile),
                ),

                // Sign Out
                _NavItem(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  route: '',
                  isSelected: false,
                  onTap: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signOut();
                    if (context.mounted) {
                      context.go(RouteConstants.home);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Content area
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
