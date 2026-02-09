# Exult - Providers & State Management

## Framework: Flutter Riverpod (^2.4.9)

## Repository Providers (DI)
- `authRepositoryProvider` → FirebaseAuthRepository
- `userRepositoryProvider` → FirebaseUserRepository
- `bookRepositoryProvider` → FirebaseBookRepository
- `loanRepositoryProvider` → FirebaseLoanRepository
- `subscriptionRepositoryProvider` → FirebaseSubscriptionRepository

## Auth Providers (`presentation/providers/auth_provider.dart`)
- `authStateProvider` - StreamProvider<User?> - Firebase auth user stream
- `currentUserProvider` - StreamProvider<UserModel?> - Full user model
- `authControllerProvider` - StateNotifierProvider<AuthController, AsyncValue<void>>
  - Methods: signIn, signUp, signOut, resetPassword

## Book Providers (`presentation/providers/books_provider.dart`)
- `availableBooksProvider` - StreamProvider<List<Book>> - Available books only
- `allBooksProvider` - StreamProvider<List<Book>> - All books (admin)
- `bookByIdProvider(bookId)` - FutureProvider.family<Book, String>
- `bookSearchProvider(query)` - FutureProvider.family<List<Book>, String>
- `booksByCategoryProvider(category)` - FutureProvider.family
- `categoryFilterProvider` - StateNotifierProvider<CategoryFilterNotifier, String?> - Single category filter (legacy)
- `selectedCategoriesProvider` - StateProvider<Set<String>> - Multi-select categories
- `selectedGenresProvider` - StateProvider<Set<String>> - Multi-select genres
- `filteredBooksProvider` - StreamProvider<List<Book>> - Filtered by single category
- `allBookCategoriesProvider` - Provider<Set<String>> - Distinct categories from available books
- `allBookCategoriesAdminProvider` - Provider<Set<String>> - Distinct categories from ALL books (admin)
- `allBookGenresProvider` - Provider<Set<String>> - Distinct genres from available books
- `allBookGenresAdminProvider` - Provider<Set<String>> - Distinct genres from ALL books (admin)

## Subscription & Loan Providers (`presentation/providers/subscription_provider.dart`)
- `loanRepositoryProvider` - Provider<LoanRepository> - DI for loan repo
- `subscriptionRepositoryProvider` - Provider<SubscriptionRepository> - DI for subscription repo
- `activeSubscriptionProvider` - StreamProvider<Subscription?>
- `hasActiveSubscriptionProvider` - Provider<bool>
- `canBorrowMoreProvider` - Provider<bool>
- `remainingBooksProvider` - Provider<int>
- `subscriptionControllerProvider` - StateNotifierProvider
  - Methods: createSubscription, cancelSubscription
- `myLoansProvider` - StreamProvider<List<Loan>> - Current user's loans
- `loanControllerProvider` - StateNotifierProvider<LoanController, AsyncValue<void>>
  - Methods: borrowBook(book), returnBook(loan)

## Admin Providers (`presentation/providers/admin_provider.dart`)
- `isAdminProvider` - Provider<bool> - Check admin role
- `allUsersProvider` - StreamProvider<List<UserModel>>
- `allLoansProvider` - StreamProvider<List<Loan>>
- `usersWithDetailsProvider` - FutureProvider - Users + subscription + loan count
- `singleUserDetailsProvider(userId)` - FutureProvider.family
- `userLoansProvider(userId)` - FutureProvider.family
- `userActiveLoansProvider(userId)` - FutureProvider.family
- `loanWithBookProvider(loanId)` - FutureProvider.family
- `dashboardMetricsProvider` - FutureProvider - Analytics data
- `dashboardDateRangeProvider` - StateProvider<DateTimeRange>

## Key Repository Methods

### FirebaseAuthRepository
- signInWithEmailAndPassword(email, password) → UserModel
- registerWithEmailAndPassword(email, password, displayName) → UserModel
- signOut()
- sendPasswordResetEmail(email)
- authStateChanges → Stream<User?>

### FirebaseBookRepository
- getAvailableBooks() → Stream<List<Book>>
- getAllBooks() → Stream<List<Book>>
- getBookById(bookId) → Book
- searchBooks(query) → List<Book> (client-side)
- createBook(book), updateBook(book), deleteBook(bookId)

### FirebaseLoanRepository
- getUserLoans(userId) → List<Loan>
- watchUserLoans(userId) → Stream<List<Loan>>
- getActiveLoans(userId) → List<Loan>
- createLoan(loan) → Loan
- returnLoan(loanId)
- getActiveLoanCount(userId) → int

### FirebaseSubscriptionRepository
- getActiveSubscription(userId) → Subscription?
- watchActiveSubscription(userId) → Stream<Subscription?>
- createSubscription(sub) → Subscription
- cancelSubscription(subId)
- incrementBooksCount(subId), decrementBooksCount(subId)
