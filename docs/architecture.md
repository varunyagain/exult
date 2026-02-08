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
│   │   │   ├── category_tree.dart         # AttributeNode class + ECORFAN tree (PENDING: rename to attribute_tree.dart)
│   │   │   └── genre_tree.dart            # Writing genre tree (uses AttributeNode)
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
│       │   ├── books_provider.dart        # Book streams, search, category/genre filter
│       │   ├── subscription_provider.dart # Subscription state, controller
│       │   └── admin_provider.dart        # Admin metrics, user details
│       ├── screens/
│       │   ├── home/home_screen.dart
│       │   ├── auth/sign_in_screen.dart
│       │   ├── auth/sign_up_screen.dart
│       │   ├── books/browse_books_screen.dart   # Dual tree sidebar (category + genre)
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
│       │       ├── admin_users_screen.dart         # User list (no summary cards)
│       │       ├── admin_user_detail_screen.dart   # User detail + loans
│       │       ├── admin_books_screen.dart         # Book catalog mgmt + BookFormDialog
│       │       └── admin_financials_screen.dart    # Revenue analytics
│       └── widgets/
│           ├── cards/book_card.dart                # Book grid item
│           └── attribute_tree_widget.dart          # AttributeTreeWidget + AttributePickerDialog
├── exult_flutter/tool/
│   └── seed_books.dart                            # Standalone seed script
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
  /signin              → SignInScreen (redirects to /admin or /books after login)
  /signup              → SignUpScreen (redirects to /admin or /books after login)

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

App URL: https://exult-web-prod-3.web.app
```

## Firebase Collections
- `users/` - User documents (UID as doc ID)
- `books/` - Book catalog
- `loans/` - Loan records
- `subscriptions/` - User subscriptions
- `contacts/` - Contact form submissions
- `mail/` - Outgoing emails (consumed by Firebase Trigger Email extension)

## Firebase Storage Paths
- `book_covers/` - Book cover images
- `profile_pictures/` - User profile images

## Firestore Security Rules (`exult_flutter/firestore.rules`)
- `users/` - Authenticated users can read; users can create/update own doc
- `books/` - Public read; create open (for seeding); admin/owner can update/delete
- `subscriptions/` - Owner or admin can read/update; owner can create; admin can delete
- `loans/` - Borrower or admin can read/update; authenticated users can create
- `contacts/` - Public create; admin can read/update/delete
- `mail/` - Admin-only create; no read/update/delete (extension processes docs)

## Shared Attribute Tree System

Both category and genre filtering use the same widget system:
- **`AttributeNode`** - Generic tree node (name + children), defined in `category_tree.dart`
- **`AttributeTreeWidget`** - Collapsible tree with tri-state checkboxes, search filtering
  - Props: `treeData`, `title`, `icon`, `availableValues`, `selectedValues`, `onSelectionChanged`, `searchQuery`
  - Only renders nodes where `availableValues` contains the name (or a descendant's name)
  - Parent auto-selection: selecting a child also selects ancestors; deselecting removes orphaned ancestors
- **`AttributePickerDialog`** - Dialog wrapper around `AttributeTreeWidget` with search bar
  - Static methods: `show()` for categories, `showGenre()` for genres (use full tree names)
  - For filter dialogs: callers pass book-derived values as `allNames` + `initialSelection`
  - For form dialogs (add/edit book): callers use static methods with full tree

## Implementation Notes
1. Book search is client-side string matching (title/author) - ready for Algolia
2. Subscription expiry checked on every read, auto-updated
3. Loan overdue status computed from dueDate vs now (not stored)
4. Category & genre filtering via dual tree sidebar (browse) and picker dialog buttons (admin)
5. Admin metrics calculated on-demand from data streams
6. Seed data runs once on startup if books collection empty
7. GoRouter redirects based on authState + user role; waits for user data to load before redirecting to avoid race conditions
8. All dates stored as Firestore Timestamps, converted to DateTime in models
9. Roles: subscriber (default) and admin
10. Static HTML prices differ from Flutter app (Flutter is canonical)
11. Admin users are redirected to `/admin` dashboard on login and from home page
12. When admin adds a user, an invite email is sent via Firestore `mail` collection (requires Firebase Trigger Email extension with SMTP configured)
13. Browse books auto-selects all categories/genres from loaded books on first load (via `_categoriesInitialized`/`_genresInitialized` flags)
14. Manage Books filter dialogs read from admin providers to get book-derived values, auto-select when empty
15. Manage Books DataTable has Genres column (purple badges) after Categories column (primary-colored badges)
