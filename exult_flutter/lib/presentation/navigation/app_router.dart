import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/screens/auth/sign_in_screen.dart';
import 'package:exult_flutter/presentation/screens/auth/sign_up_screen.dart';
import 'package:exult_flutter/presentation/screens/home/home_screen.dart';
import 'package:exult_flutter/presentation/screens/books/browse_books_screen.dart';
import 'package:exult_flutter/presentation/screens/books/book_detail_screen.dart';
import 'package:exult_flutter/presentation/screens/profile/profile_screen.dart';
import 'package:exult_flutter/presentation/screens/loans/my_loans_screen.dart';
import 'package:exult_flutter/presentation/screens/pricing/pricing_screen.dart';
import 'package:exult_flutter/presentation/screens/how_it_works/how_it_works_screen.dart';
import 'package:exult_flutter/presentation/screens/contact/contact_us_screen.dart';
import 'package:exult_flutter/presentation/screens/subscribe/subscribe_screen.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_shell.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_users_screen.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_user_detail_screen.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_books_screen.dart';
import 'package:exult_flutter/presentation/screens/admin/admin_financials_screen.dart';

/// Notifier that triggers GoRouter redirect re-evaluation when auth state changes
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

/// Provider for the router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: RouteConstants.home,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == RouteConstants.signIn ||
          state.matchedLocation == RouteConstants.signUp;

      // Redirect to sign in if trying to access protected route while not authenticated
      if (!isAuthenticated && !isAuthRoute && _isProtectedRoute(state.matchedLocation)) {
        return RouteConstants.signIn;
      }

      // Redirect away from auth routes when already authenticated
      if (isAuthenticated && isAuthRoute) {
        final currentUserState = ref.read(currentUserProvider);
        // Wait for user data to load before deciding where to redirect
        if (currentUserState.isLoading) {
          return null;
        }
        final currentUser = currentUserState.valueOrNull;
        if (currentUser?.isAdmin == true) {
          return RouteConstants.admin;
        }
        return RouteConstants.books;
      }

      // Redirect admins from home page to admin dashboard
      if (isAuthenticated && state.matchedLocation == RouteConstants.home) {
        final currentUserState = ref.read(currentUserProvider);
        if (currentUserState.isLoading) {
          return null;
        }
        final currentUser = currentUserState.valueOrNull;
        if (currentUser?.isAdmin == true) {
          return RouteConstants.admin;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Public routes
      GoRoute(
        path: RouteConstants.home,
        pageBuilder: (context, state) => const MaterialPage(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.signIn,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignUpScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.pricing,
        pageBuilder: (context, state) => const MaterialPage(
          child: PricingScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.howItWorks,
        pageBuilder: (context, state) => const MaterialPage(
          child: HowItWorksScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.contact,
        pageBuilder: (context, state) => const MaterialPage(
          child: ContactUsScreen(),
        ),
      ),

      // Protected routes (require authentication)
      GoRoute(
        path: RouteConstants.books,
        pageBuilder: (context, state) => const MaterialPage(
          child: BrowseBooksScreen(),
        ),
        routes: [
          GoRoute(
            path: ':bookId',
            pageBuilder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              return MaterialPage(
                child: BookDetailScreen(bookId: bookId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.profile,
        pageBuilder: (context, state) => const MaterialPage(
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.loans,
        pageBuilder: (context, state) => const MaterialPage(
          child: MyLoansScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.subscribe,
        pageBuilder: (context, state) => const MaterialPage(
          child: SubscribeScreen(),
        ),
      ),

      // Admin routes (require authentication + admin role) — wrapped in ShellRoute
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.admin,
            pageBuilder: (context, state) => const MaterialPage(
              child: AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminSubscribers,
            pageBuilder: (context, state) => const MaterialPage(
              child: AdminUsersScreen(),
            ),
            routes: [
              GoRoute(
                path: ':userId',
                pageBuilder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return MaterialPage(
                    child: AdminUserDetailScreen(userId: userId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteConstants.adminBooks,
            pageBuilder: (context, state) => const MaterialPage(
              child: AdminBooksScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminFinancials,
            pageBuilder: (context, state) => const MaterialPage(
              child: AdminFinancialsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Error: ${state.error}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Check if a route requires authentication
bool _isProtectedRoute(String location) {
  const protectedRoutes = [
    RouteConstants.books,
    RouteConstants.profile,
    RouteConstants.loans,
    RouteConstants.subscribe,
    RouteConstants.admin,
    RouteConstants.adminSubscribers,
    RouteConstants.adminBooks,
    RouteConstants.adminFinancials,
  ];

  return protectedRoutes.any((route) => location.startsWith(route));
}
