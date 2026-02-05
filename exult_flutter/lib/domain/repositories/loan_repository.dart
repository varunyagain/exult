import 'package:exult_flutter/domain/models/loan_model.dart';

/// Abstract repository interface for loan operations
abstract class LoanRepository {
  /// Get all loans for a specific user
  Future<List<Loan>> getUserLoans(String userId);

  /// Get a stream of all loans for a specific user
  Stream<List<Loan>> watchUserLoans(String userId);

  /// Get active loans for a specific user
  Future<List<Loan>> getActiveLoans(String userId);

  /// Get a stream of active loans for a specific user
  Stream<List<Loan>> watchActiveLoans(String userId);

  /// Get a specific loan by ID
  Future<Loan?> getLoanById(String loanId);

  /// Get all loans (admin only)
  Future<List<Loan>> getAllLoans();

  /// Get a stream of all loans (admin only)
  Stream<List<Loan>> watchAllLoans();

  /// Create a new loan
  Future<Loan> createLoan(Loan loan);

  /// Update an existing loan
  Future<void> updateLoan(Loan loan);

  /// Return a book (update loan status to returned)
  Future<void> returnLoan(String loanId);

  /// Get loan count for a user
  Future<int> getActiveLoanCount(String userId);
}
