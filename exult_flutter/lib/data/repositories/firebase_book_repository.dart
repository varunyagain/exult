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

  @override
  Stream<List<Book>> getUserBooks(String userId) {
    return _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('contributorIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<Book?> findBookByIsbn(String isbn) async {
    // Query by ISBN only — no composite index needed.
    // Filter out pending books in code.
    final snapshot = await _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('isbn', isEqualTo: isbn)
        .get();

    if (snapshot.docs.isEmpty) return null;
    for (final doc in snapshot.docs) {
      final book = Book.fromJson({...doc.data(), 'id': doc.id});
      if (!book.isPending) return book;
    }
    return null;
  }

  @override
  Future<void> addCopyToBook(String bookId, String userId) async {
    final docRef = _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Book not found');

      final data = doc.data()!;
      final contributors = Map<String, int>.from(
        (data['contributors'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {},
      );
      final contributorIds = List<String>.from(
        (data['contributorIds'] as List<dynamic>?) ?? [],
      );
      final totalCopies = (data['totalCopies'] as num?)?.toInt() ?? 1;
      final availableCopies = (data['availableCopies'] as num?)?.toInt() ?? 1;

      contributors[userId] = (contributors[userId] ?? 0) + 1;
      if (!contributorIds.contains(userId)) {
        contributorIds.add(userId);
      }

      transaction.update(docRef, {
        'contributors': contributors,
        'contributorIds': contributorIds,
        'totalCopies': totalCopies + 1,
        'availableCopies': availableCopies + 1,
      });
    });
  }

  @override
  Future<void> removeCopyFromBook(String bookId, String userId) async {
    final docRef = _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Book not found');

      final data = doc.data()!;
      final contributors = Map<String, int>.from(
        (data['contributors'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {},
      );
      final contributorIds = List<String>.from(
        (data['contributorIds'] as List<dynamic>?) ?? [],
      );
      final totalCopies = (data['totalCopies'] as num?)?.toInt() ?? 1;
      final availableCopies = (data['availableCopies'] as num?)?.toInt() ?? 1;

      final userCopies = contributors[userId] ?? 0;
      if (userCopies <= 0) throw Exception('No copies to remove');

      if (userCopies == 1) {
        contributors.remove(userId);
        contributorIds.remove(userId);
      } else {
        contributors[userId] = userCopies - 1;
      }

      transaction.update(docRef, {
        'contributors': contributors,
        'contributorIds': contributorIds,
        'totalCopies': (totalCopies - 1).clamp(0, totalCopies),
        'availableCopies': (availableCopies - 1).clamp(0, availableCopies),
      });
    });
  }

  @override
  Future<void> approveBook(String bookId) async {
    await _firestore
        .collection(FirebaseConstants.booksCollection)
        .doc(bookId)
        .update({'status': BookStatus.available.name});
  }
}
