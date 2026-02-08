# Exult - Full Architecture & Codebase Documentation

## Directory Structure

```
exult/
├── exult_flutter/lib/
│   ├── main.dart                          # Entry point, Firebase init
│   ├── app.dart                           # Root MaterialApp (ConsumerWidget)
│   ├── firebase_options.dart              # Generated Firebase config (web)
│   ├── config/
│   │   └── firebase_config.dart           # Firebase settings
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # Pricing, limits, contact info
│   │   │   ├── route_constants.dart       # Route path strings
│   │   │   ├── firebase_constants.dart    # Collection/field names
│   │   │   └── category_tree.dart         # ECORFAN ISBN classification
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Indigo primary, Material 3
│   │   └── utils/
│   │       └── validators.dart            # Form validation
│   ├── domain/
│   │   ├── models/
│   │   │   ├── user_model.dart            # UserModel, UserRole, UserAddress
│   │   │   ├── book_model.dart            # Book, BookStatus, BookOwnerType
│   │   │   ├── loan_model.dart            # Loan, LoanStatus
│   │   │   ├── subscription_model.dart    # Subscription, SubscriptionTier
│   │   │   └── contact_model.dart         # Contact form model
│   │   └── repositories/                  # Abstract interfaces
│   │       ├── auth_repository.dart
│   │       ├── user_repository.dart
│   │       ├── book_repository.dart
│   │       ├── loan_repository.dart
│   │       └── subscription_repository.dart
│   ├── data/
│   │   ├── seed_data.dart                 # 5 sample books seeder
│   │   └── repositories/                  # Firebase implementations
│   │       ├── firebase_auth_repository.dart
│   │       ├── firebase_user_repository.dart
│   │       ├── firebase_book_repository.dart
│   │       ├── firebase_loan_repository.dart
│   │       └── firebase_subscription_repository.dart
│   └── presentation/
│       ├── navigation/
│       │   └── app_router.dart            # GoRouter with auth redirects
│       ├── providers/
│       │   ├── auth_provider.dart         # Auth state, controller
│       │   ├── books_provider.dart        # Book streams, search, category filter
│       │   ├── subscription_provider.dart # Subscription state, controller
│       │   └── admin_provider.dart        # Admin metrics, user details
│       ├── screens/
│       │   ├── home/home_screen.dart
│       │   ├── auth/sign_in_screen.dart
│       │   ├── auth/sign_up_screen.dart
│       │   ├── books/browse_books_screen.dart
│       │   ├── books/book_detail_screen.dart
│       │   ├── loans/my_loans_screen.dart
│       │   ├── profile/profile_screen.dart
│       │   ├── subscribe/subscribe_screen.dart
│       │   ├── pricing/pricing_screen.dart
│       │   ├── how_it_works/how_it_works_screen.dart
│       │   ├── contact/contact_us_screen.dart
│       │   └── admin/
│       │       ├── admin_shell.dart               # Sidebar nav container
│       │       ├── admin_dashboard_screen.dart     # Metrics & charts
│       │       ├── admin_users_screen.dart         # User list
│       │       ├── admin_user_detail_screen.dart   # User detail + loans
│       │       ├── admin_books_screen.dart         # Book catalog mgmt
│       │       └── admin_financials_screen.dart    # Revenue analytics
│       └── widgets/
│           ├── cards/book_card.dart                # Book grid item
│           └── category_tree_widget.dart           # Category selector
├── index.html, pricing.html, etc.                 # Static HTML site
├── css/styles.css
└── assets/images/exult-logo.svg
```

## Route Structure

```
Public (no auth):
  /                    → HomeScreen
  /pricing             → PricingScreen
  /how-it-works        → HowItWorksScreen
  /contact             → ContactUsScreen
  /signin              → SignInScreen
  /signup              → SignUpScreen

Protected (auth required):
  /books               → BrowseBooksScreen
  /books/:bookId       → BookDetailScreen
  /profile             → ProfileScreen
  /loans               → MyLoansScreen
  /subscribe           → SubscribeScreen

Admin (auth + admin role):
  /admin               → AdminShell + AdminDashboardScreen
  /admin/subscribers   → AdminUsersScreen
  /admin/subscribers/:userId → AdminUserDetailScreen
  /admin/books         → AdminBooksScreen
  /admin/financials    → AdminFinancialsScreen
```

## Key Constants

```
Pricing (INR):
  1 book/month: 99    | annual: 999
  3 books/month: 199  | annual: 1999
  5 books/month: 299  | annual: 2999

Defaults:
  Deposit: 200 INR
  Loan duration: 14 days
  Books per page: 12

Theme:
  Primary: Indigo (#4F46E5)
  Secondary: Green (#10B981)
  Background: #F7F9FC

Contact:
  hello@exultbooks.in
  +91 98765 43210
```

## Firebase Collections
- `users/` - User documents (UID as doc ID)
- `books/` - Book catalog
- `loans/` - Loan records
- `subscriptions/` - User subscriptions
- `contacts/` - Contact form submissions

## Firebase Storage Paths
- `book_covers/` - Book cover images
- `profile_pictures/` - User profile images

## Implementation Notes
1. Book search is client-side string matching (title/author) - ready for Algolia
2. Subscription expiry checked on every read, auto-updated
3. Loan overdue status computed from dueDate vs now (not stored)
4. Category filtering supports single-select and multi-select (tree-based)
5. Admin metrics calculated on-demand from data streams
6. Seed data runs once on startup if books collection empty
7. GoRouter redirects based on authState + user role
8. All dates stored as Firestore Timestamps, converted to DateTime in models
9. Roles: subscriber (default) and admin
10. Static HTML prices differ from Flutter app (Flutter is canonical)
