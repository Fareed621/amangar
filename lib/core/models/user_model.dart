// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../services/encryption_service.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.uid,
    required this.email,
    this.role,
    required this.name,
    this.phone,
    this.city,
    this.profilePhoto,
    this.serviceCategory,
    required this.isVerified,
    required this.rating,
    required this.totalReviews,
    required this.isBanned,
    required this.isAdmin,
    required this.isDeleted,
    required this.isOnline,
    this.lastActiveAt,
    required this.onboardingComplete,
    this.fcmToken,
    required this.notificationSettings,
    this.createdAt,
    this.updatedAt,
    required this.schemaVersion,
  });

  final String id;
  final String uid;
  final String email;
  final String? role;
  final String name;
  final String? phone;
  final String? city;
  final String? profilePhoto;
  final String? serviceCategory;
  final bool isVerified;
  final double rating;
  final int totalReviews;
  final bool isBanned;
  final bool isAdmin;
  final bool isDeleted;
  final bool isOnline;
  final Timestamp? lastActiveAt;
  final bool onboardingComplete;
  final String? fcmToken;
  final Map<String, dynamic> notificationSettings;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final int schemaVersion;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      role: data['role'] as String?,
      name: data['name'] as String? ?? '',
      phone: EncryptionService.instance.decryptNullable(data['phone'] as String?),
      city: data['city'] as String?,
      profilePhoto: EncryptionService.instance.decryptNullable(data['profilePhoto'] as String?),
      serviceCategory: data['serviceCategory'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      isBanned: data['isBanned'] as bool? ?? false,
      isAdmin: data['isAdmin'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isOnline: data['isOnline'] as bool? ?? false,
      lastActiveAt: data['lastActiveAt'] as Timestamp?,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      notificationSettings:
          data['notificationSettings'] as Map<String, dynamic>? ?? {},
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      schemaVersion: data['schemaVersion'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'role': role,
        'name': name,
        'phone': phone,
        'city': city,
        'profilePhoto': profilePhoto,
        'serviceCategory': serviceCategory,
        'isVerified': isVerified,
        'rating': rating,
        'totalReviews': totalReviews,
        'isBanned': isBanned,
        'isAdmin': isAdmin,
        'isDeleted': isDeleted,
        'isOnline': isOnline,
        'lastActiveAt': lastActiveAt,
        'onboardingComplete': onboardingComplete,
        'fcmToken': fcmToken,
        'notificationSettings': notificationSettings,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'schemaVersion': schemaVersion,
      };

  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? role,
    String? name,
    String? phone,
    String? city,
    String? profilePhoto,
    String? serviceCategory,
    bool? isVerified,
    double? rating,
    int? totalReviews,
    bool? isBanned,
    bool? isAdmin,
    bool? isDeleted,
    bool? isOnline,
    Timestamp? lastActiveAt,
    bool? onboardingComplete,
    String? fcmToken,
    Map<String, dynamic>? notificationSettings,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? schemaVersion,
  }) =>
      UserModel(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        email: email ?? this.email,
        role: role ?? this.role,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        isVerified: isVerified ?? this.isVerified,
        rating: rating ?? this.rating,
        totalReviews: totalReviews ?? this.totalReviews,
        isBanned: isBanned ?? this.isBanned,
        isAdmin: isAdmin ?? this.isAdmin,
        isDeleted: isDeleted ?? this.isDeleted,
        isOnline: isOnline ?? this.isOnline,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        fcmToken: fcmToken ?? this.fcmToken,
        notificationSettings:
            notificationSettings ?? this.notificationSettings,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  List<Object?> get props => [
        id, uid, email, role, name, phone, city, profilePhoto,
        serviceCategory, isVerified, rating, totalReviews, isBanned,
        isAdmin, isDeleted, isOnline, lastActiveAt, onboardingComplete,
        fcmToken, notificationSettings, createdAt, updatedAt, schemaVersion,
      ];
}
