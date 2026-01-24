import 'package:cloud_firestore/cloud_firestore.dart';

/// Loan status in the system
enum LoanStatus {
  active,
  returned,
  overdue;

  String toJson() => name;

  static LoanStatus fromJson(String json) {
    return LoanStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => LoanStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.returned:
        return 'Returned';
      case LoanStatus.overdue:
        return 'Overdue';
    }
  }
}

/// Loan model representing a book loan
class Loan {
  final String id;
  final String bookId;
  final String borrowerId;
  final String subscriptionId;
  final LoanStatus status;
  final double depositAmount;
  final bool depositPaid;
  final DateTime borrowedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;

  const Loan({
    required this.id,
    required this.bookId,
    required this.borrowerId,
    required this.subscriptionId,
    required this.status,
    required this.depositAmount,
    required this.depositPaid,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'borrowerId': borrowerId,
      'subscriptionId': subscriptionId,
      'status': status.toJson(),
      'depositAmount': depositAmount,
      'depositPaid': depositPaid,
      'borrowedAt': Timestamp.fromDate(borrowedAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnedAt': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      borrowerId: json['borrowerId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      status: LoanStatus.fromJson(json['status'] as String? ?? 'active'),
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      depositPaid: json['depositPaid'] as bool? ?? false,
      borrowedAt: (json['borrowedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (json['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnedAt: (json['returnedAt'] as Timestamp?)?.toDate(),
    );
  }

  Loan copyWith({
    String? id,
    String? bookId,
    String? borrowerId,
    String? subscriptionId,
    LoanStatus? status,
    double? depositAmount,
    bool? depositPaid,
    DateTime? borrowedAt,
    DateTime? dueDate,
    DateTime? returnedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      borrowerId: borrowerId ?? this.borrowerId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      status: status ?? this.status,
      depositAmount: depositAmount ?? this.depositAmount,
      depositPaid: depositPaid ?? this.depositPaid,
      borrowedAt: borrowedAt ?? this.borrowedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }

  bool get isActive => status == LoanStatus.active && !isOverdue;
  bool get isReturned => status == LoanStatus.returned;
  bool get isOverdue => status != LoanStatus.returned && dueDate.isBefore(DateTime.now());

  int get daysRemaining {
    if (isReturned) return 0;
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
}
