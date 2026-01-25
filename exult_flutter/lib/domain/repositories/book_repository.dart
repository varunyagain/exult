import 'package:exult_flutter/domain/models/book_model.dart';

/// Abstract repository interface for book operations
abstract class BookRepository {
  /// Get a stream of available books
  Stream<List<Book>> getAvailableBooks();

  /// Get a stream of all books (including borrowed)
  Stream<List<Book>> getAllBooks();

  /// Get a specific book by ID
  Future<Book> getBookById(String bookId);

  /// Search books by title or author
  Future<List<Book>> searchBooks(String query);

  /// Get books by category
  Future<List<Book>> getBooksByCategory(String category);

  /// Create a new book
  Future<void> createBook(Book book);

  /// Update an existing book
  Future<void> updateBook(Book book);

  /// Delete a book
  Future<void> deleteBook(String bookId);

  /// Update book status
  Future<void> updateBookStatus(String bookId, BookStatus status);
}
