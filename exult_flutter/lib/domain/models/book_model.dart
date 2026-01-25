import 'package:cloud_firestore/cloud_firestore.dart';

/// Book status in the system
enum BookStatus {
  available,
  borrowed;

  String toJson() => name;

  static BookStatus fromJson(String json) {
    return BookStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => BookStatus.available,
    );
  }

  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.borrowed:
        return 'Borrowed';
    }
  }
}

/// Book owner type
enum BookOwnerType {
  business,
  user;

  String toJson() => name;

  static BookOwnerType fromJson(String json) {
    return BookOwnerType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => BookOwnerType.business,
    );
  }
}

/// Book model representing a book in the catalog
class Book {
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String description;
  final String? coverImageUrl;
  final BookOwnerType ownerType;
  final List<String> categories;
  final double depositAmount;
  final BookStatus status;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.description,
    this.coverImageUrl,
    required this.ownerType,
    required this.categories,
    required this.depositAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'ownerType': ownerType.toJson(),
      'categories': categories,
      'depositAmount': depositAmount,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String?,
      description: json['description'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      ownerType: BookOwnerType.fromJson(json['ownerType'] as String? ?? 'business'),
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      status: BookStatus.fromJson(json['status'] as String? ?? 'available'),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? description,
    String? coverImageUrl,
    BookOwnerType? ownerType,
    List<String>? categories,
    double? depositAmount,
    BookStatus? status,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      ownerType: ownerType ?? this.ownerType,
      categories: categories ?? this.categories,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAvailable => status == BookStatus.available;
  bool get isBorrowed => status == BookStatus.borrowed;
}
