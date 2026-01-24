import 'package:cloud_firestore/cloud_firestore.dart';

/// Contact form submission model
class Contact {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime createdAt;
  final bool replied;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.createdAt,
    this.replied = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'replied': replied,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      message: json['message'] as String,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replied: json['replied'] as bool? ?? false,
    );
  }

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? message,
    DateTime? createdAt,
    bool? replied,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      replied: replied ?? this.replied,
    );
  }
}
