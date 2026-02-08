import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/data/repositories/firebase_book_repository.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/repositories/book_repository.dart';

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
