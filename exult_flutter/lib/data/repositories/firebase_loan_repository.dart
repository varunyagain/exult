import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';
import 'package:exult_flutter/domain/models/loan_model.dart';
import 'package:exult_flutter/domain/repositories/loan_repository.dart';

class FirebaseLoanRepository implements LoanRepository {
  final FirebaseFirestore _firestore;

  FirebaseLoanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConstants.loansCollection);

  @override
  Future<List<Loan>> getUserLoans(String userId) async {
    final snapshot = await _collection
        .where('borrowerId', isEqualTo: userId)
        .orderBy('borrowedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Loan.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Stream<List<Loan>> watchUserLoans(String userId) {
    return _collection
        .where('borrowerId', isEqualTo: userId)
        .orderBy('borrowedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Loan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<List<Loan>> getActiveLoans(String userId) async {
    final snapshot = await _collection
        .where('borrowerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      return Loan.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Stream<List<Loan>> watchActiveLoans(String userId) {
    return _collection
        .where('borrowerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Loan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<Loan?> getLoanById(String loanId) async {
    final doc = await _collection.doc(loanId).get();

    if (!doc.exists) {
      return null;
    }

    return Loan.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<List<Loan>> getAllLoans() async {
    final snapshot = await _collection
        .orderBy('borrowedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Loan.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Stream<List<Loan>> watchAllLoans() {
    return _collection
        .orderBy('borrowedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Loan.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<Loan> createLoan(Loan loan) async {
    final docRef = _collection.doc();
    final loanWithId = loan.copyWith(id: docRef.id);

    await docRef.set(loanWithId.toJson());

    return loanWithId;
  }

  @override
  Future<void> updateLoan(Loan loan) async {
    await _collection.doc(loan.id).update(loan.toJson());
  }

  @override
  Future<void> returnLoan(String loanId) async {
    await _collection.doc(loanId).update({
      'status': 'returned',
      'returnedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<int> getActiveLoanCount(String userId) async {
    final snapshot = await _collection
        .where('borrowerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
