import 'package:cloud_firestore/cloud_firestore.dart';

/// Book status in the system
enum BookStatus {
  pending,
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
      case BookStatus.pending:
        return 'Pending';
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
  final String? ownerId;
  final Map<String, int> contributors;
  final List<String> contributorIds;
  final List<String> categories;
  final List<String> genres;
  final double depositAmount;
  final BookStatus status;
  final int totalCopies;
  final int availableCopies;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.description,
    this.coverImageUrl,
    required this.ownerType,
    this.ownerId,
    this.contributors = const {},
    this.contributorIds = const [],
    required this.categories,
    this.genres = const [],
    required this.depositAmount,
    required this.status,
    this.totalCopies = 1,
    this.availableCopies = 1,
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
      'ownerId': ownerId,
      'contributors': contributors,
      'contributorIds': contributorIds,
      'categories': categories,
      'genres': genres,
      'depositAmount': depositAmount,
      'status': status.toJson(),
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
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
      ownerId: json['ownerId'] as String?,
      contributors: (json['contributors'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      contributorIds: (json['contributorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      status: BookStatus.fromJson(json['status'] as String? ?? 'available'),
      totalCopies: json['totalCopies'] as int? ?? 1,
      availableCopies: json['availableCopies'] as int? ?? 1,
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
    String? ownerId,
    Map<String, int>? contributors,
    List<String>? contributorIds,
    List<String>? categories,
    List<String>? genres,
    double? depositAmount,
    BookStatus? status,
    int? totalCopies,
    int? availableCopies,
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
      ownerId: ownerId ?? this.ownerId,
      contributors: contributors ?? this.contributors,
      contributorIds: contributorIds ?? this.contributorIds,
      categories: categories ?? this.categories,
      genres: genres ?? this.genres,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => status == BookStatus.pending;
  bool get isAvailable => status == BookStatus.available;
  bool get isBorrowed => status == BookStatus.borrowed;
}
