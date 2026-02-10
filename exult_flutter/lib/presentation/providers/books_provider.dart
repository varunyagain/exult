import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/data/repositories/firebase_book_repository.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/repositories/book_repository.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';

/// Provider for the book repository
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return FirebaseBookRepository();
});

/// Provider for available books stream
final availableBooksProvider = StreamProvider<List<Book>>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getAvailableBooks();
});

/// Provider for all books stream (admin use)
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getAllBooks();
});

/// Provider for getting a specific book by ID
final bookByIdProvider = FutureProvider.family<Book, String>((ref, bookId) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getBookById(bookId);
});

/// Provider for book search
final bookSearchProvider = FutureProvider.family<List<Book>, String>((ref, query) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  if (query.isEmpty) {
    return [];
  }
  return bookRepository.searchBooks(query);
});

/// Provider for books by category
final booksByCategoryProvider = FutureProvider.family<List<Book>, String>((ref, category) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getBooksByCategory(category);
});

/// State notifier for managing selected category filter (single)
class CategoryFilterNotifier extends StateNotifier<String?> {
  CategoryFilterNotifier() : super(null);

  void setCategory(String? category) {
    state = category;
  }

  void clearFilter() {
    state = null;
  }
}

/// Provider for category filter state (single, legacy)
final categoryFilterProvider = StateNotifierProvider<CategoryFilterNotifier, String?>((ref) {
  return CategoryFilterNotifier();
});

/// Provider for selected categories set (tree-based multi-select)
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for selected genres set (tree-based multi-select)
final selectedGenresProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for filtered books based on selected category
final filteredBooksProvider = StreamProvider<List<Book>>((ref) {
  final category = ref.watch(categoryFilterProvider);
  final bookRepository = ref.watch(bookRepositoryProvider);

  if (category == null) {
    // Return all available books if no category filter
    return bookRepository.getAvailableBooks();
  } else {
    // Return books filtered by category as a stream
    return Stream.fromFuture(bookRepository.getBooksByCategory(category));
  }
});

/// Provider that collects all distinct category names across all books.
final allBookCategoriesProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(availableBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final categories = <String>{};
  for (final book in books) {
    categories.addAll(book.categories);
  }
  return categories;
});

/// Provider that collects all distinct category names across ALL books (admin).
final allBookCategoriesAdminProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(allBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final categories = <String>{};
  for (final book in books) {
    categories.addAll(book.categories);
  }
  return categories;
});

/// Provider that collects all distinct genre names across available books.
final allBookGenresProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(availableBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final genres = <String>{};
  for (final book in books) {
    genres.addAll(book.genres);
  }
  return genres;
});

/// Provider that collects all distinct genre names across ALL books (admin).
final allBookGenresAdminProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(allBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final genres = <String>{};
  for (final book in books) {
    genres.addAll(book.genres);
  }
  return genres;
});

/// Provider for current user's books (owned or contributed)
final userBooksProvider = StreamProvider<List<Book>>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value([]);
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getUserBooks(currentUser.uid);
});

/// Provider that collects all distinct category names across user's books.
final userBookCategoriesProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(userBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final categories = <String>{};
  for (final book in books) {
    categories.addAll(book.categories);
  }
  return categories;
});

/// Provider that collects all distinct genre names across user's books.
final userBookGenresProvider = Provider<Set<String>>((ref) {
  final booksAsync = ref.watch(userBooksProvider);
  final books = booksAsync.valueOrNull ?? [];
  final genres = <String>{};
  for (final book in books) {
    genres.addAll(book.genres);
  }
  return genres;
});

/// Selected categories for My Books filter sidebar
final selectedMyBooksCategoriesProvider = StateProvider<Set<String>>((ref) => {});

/// Selected genres for My Books filter sidebar
final selectedMyBooksGenresProvider = StateProvider<Set<String>>((ref) => {});

/// Controller for user book listing operations
class UserBookController extends StateNotifier<AsyncValue<void>> {
  final BookRepository _bookRepository;
  final String _userId;

  UserBookController(this._bookRepository, this._userId)
      : super(const AsyncValue.data(null));

  /// List a new book. If an approved book with the same ISBN exists, add a copy instead.
  Future<bool> listBook(Book book) async {
    state = const AsyncValue.loading();
    try {
      // Check for ISBN dedup
      if (book.isbn != null && book.isbn!.isNotEmpty) {
        final existing = await _bookRepository.findBookByIsbn(book.isbn!);
        if (existing != null) {
          // Add copy to existing book (auto-approved)
          await _bookRepository.addCopyToBook(existing.id, _userId);
          state = const AsyncValue.data(null);
          return true; // indicates dedup occurred
        }
      }

      // Create new book as pending
      final newBook = book.copyWith(
        ownerType: BookOwnerType.user,
        ownerId: _userId,
        contributors: {_userId: book.totalCopies},
        contributorIds: [_userId],
        status: BookStatus.pending,
      );
      await _bookRepository.createBook(newBook);
      state = const AsyncValue.data(null);
      return false; // no dedup
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Withdraw user's copy from a book
  Future<void> withdrawCopy(Book book) async {
    state = const AsyncValue.loading();
    try {
      final userCopies = book.contributors[_userId] ?? 0;

      // If user is the sole owner and book is pending, just delete it
      if (book.ownerId == _userId &&
          book.isPending &&
          book.contributorIds.length == 1) {
        await _bookRepository.deleteBook(book.id);
      } else if (userCopies > 0) {
        await _bookRepository.removeCopyFromBook(book.id, _userId);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update a pending book's details (only if user is the owner)
  Future<void> updateMyBook(Book book) async {
    state = const AsyncValue.loading();
    try {
      await _bookRepository.updateBook(book);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for user book controller
final userBookControllerProvider =
    StateNotifierProvider<UserBookController, AsyncValue<void>>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final userId = currentUser?.uid ?? '';
  return UserBookController(bookRepository, userId);
});
