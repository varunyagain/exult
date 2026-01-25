import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/domain/repositories/book_repository.dart';

class FirebaseBookRepository implements BookRepository {
  final FirebaseFirestore _firestore;

  FirebaseBookRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Book>> getAvailableBooks() {
    return _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Stream<List<Book>> getAllBooks() {
    return _firestore
        .collection(FirebaseConstants.booksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<Book> getBookById(String bookId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId)
        .get();

    if (!doc.exists) {
      throw Exception('Book not found');
    }

    return Book.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    // Simple search implementation - can be enhanced with Algolia or other search solutions
    final snapshot = await _firestore
        .collection(FirebaseConstants.booksCollection)
        .get();

    final books = snapshot.docs.map((doc) {
      return Book.fromJson({...doc.data(), 'id': doc.id});
    }).toList();

    // Filter by title or author containing the query (case-insensitive)
    final queryLower = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(queryLower) ||
          book.author.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  Future<List<Book>> getBooksByCategory(String category) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('categories', arrayContains: category)
        .get();

    return snapshot.docs.map((doc) {
      return Book.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Future<void> createBook(Book book) async {
    final docRef = _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc();

    final bookWithId = book.copyWith(id: docRef.id);

    await docRef.set(bookWithId.toJson());
  }

  @override
  Future<void> updateBook(Book book) async {
    await _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(book.id)
        .update(book.toJson());
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId)
        .delete();
  }

  @override
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    await _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId)
        .update({'status': status.name});
  }
}
