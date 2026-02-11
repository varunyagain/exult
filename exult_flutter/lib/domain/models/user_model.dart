import 'package:cloud_firestore/cloud_firestore.dart';

/// User roles in the application
enum UserRole {
  subscriber,
  admin;

  String toJson() => name;

  static UserRole fromJson(String json) {
    return UserRole.values.firstWhere(
      (role) => role.name == json,
      orElse: () => UserRole.subscriber,
    );
  }
}

/// User address model
class UserAddress {
  final String street;
  final String city;
  final String pincode;

  const UserAddress({
    required this.street,
    required this.city,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'pincode': pincode,
    };
  }

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
    );
  }

  UserAddress copyWith({
    String? street,
    String? city,
    String? pincode,
  }) {
    return UserAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
    );
  }
}

/// User model representing a user in the system
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final UserRole role;
  final UserAddress? address;
  final DateTime createdAt;
  final bool isActive;
  final List<String> favoriteBookIds;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    required this.role,
    this.address,
    required this.createdAt,
    this.isActive = true,
    this.favoriteBookIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.toJson(),
      'address': address?.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'favoriteBookIds': favoriteBookIds,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.fromJson(json['role'] as String? ?? 'subscriber'),
      address: json['address'] != null
          ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      favoriteBookIds: List<String>.from(
        (json['favoriteBookIds'] as List<dynamic>?) ?? [],
      ),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    UserAddress? address,
    DateTime? createdAt,
    bool? isActive,
    List<String>? favoriteBookIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      favoriteBookIds: favoriteBookIds ?? this.favoriteBookIds,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isSubscriber => role == UserRole.subscriber;
}
