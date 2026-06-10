// lib/core/models/provider_profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../services/encryption_service.dart';

class ProviderProfileModel extends Equatable {
  const ProviderProfileModel({
    required this.uid,
    required this.serviceCategory,
    required this.skills,
    required this.languages,
    required this.fullTimeRate,
    required this.partTimeRate,
    required this.experienceYears,
    required this.experienceLevel,
    this.bio,
    required this.portfolioPhotos,
    required this.portfolioCount,
    required this.isVerified,
    required this.verificationStatus,
    this.verifiedAt,
    required this.verificationDocuments,
    this.verificationRejectionReason,
    required this.verificationAttempts,
    required this.rating,
    required this.totalReviews,
    required this.totalCompletedBookings,
    required this.currentMonthBookings,
    required this.currentMonthEarnings,
    required this.totalEarningsTracked,
    required this.totalCancellationsByProvider,
    this.lastCancelledAt,
    this.availabilitySummary,
    this.nextAvailableDate,
    this.createdAt,
    this.updatedAt,
    required this.schemaVersion,
  });

  final String uid;
  final String serviceCategory;
  final List<String> skills;
  final List<String> languages;
  final int fullTimeRate;
  final int partTimeRate;
  final int experienceYears;
  final String experienceLevel;
  final String? bio;
  final List<String> portfolioPhotos;
  final int portfolioCount;
  final bool isVerified;
  final String verificationStatus;
  final Timestamp? verifiedAt;
  final Map<String, dynamic> verificationDocuments;
  final String? verificationRejectionReason;
  final int verificationAttempts;
  final double rating;
  final int totalReviews;
  final int totalCompletedBookings;
  final int currentMonthBookings;
  final int currentMonthEarnings;
  final int totalEarningsTracked;
  final int totalCancellationsByProvider;
  final Timestamp? lastCancelledAt;
  final String? availabilitySummary;
  final Timestamp? nextAvailableDate;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final int schemaVersion;

  factory ProviderProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    String category = data['serviceCategory'] as String? ?? '';
    if (category.isEmpty) {
      final services = data['services'] as List<dynamic>? ?? [];
      category = services.isNotEmpty ? (services.first as String? ?? '') : '';
    }
    return ProviderProfileModel(
      uid: data['uid'] as String? ?? doc.id,
      serviceCategory: category,
      skills: List<String>.from(data['skills'] as List? ?? []),
      languages: List<String>.from(data['languages'] as List? ?? []),
      fullTimeRate: data['fullTimeRate'] as int? ?? 0,
      partTimeRate: data['partTimeRate'] as int? ?? 0,
      experienceYears: data['experienceYears'] as int? ?? 0,
      experienceLevel: data['experienceLevel'] as String? ?? '0-2 years',
      bio: data['bio'] as String?,
      portfolioPhotos: List<String>.from(data['portfolioPhotos'] as List? ?? [])
          .map((url) => EncryptionService.instance.decryptData(url))
          .toList(),
      portfolioCount: data['portfolioCount'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      verificationStatus: data['verificationStatus'] as String? ?? 'not_started',
      verifiedAt: data['verifiedAt'] as Timestamp?,
      verificationDocuments: data['verificationDocuments'] as Map<String, dynamic>? ?? {},
      verificationRejectionReason: data['verificationRejectionReason'] as String?,
      verificationAttempts: data['verificationAttempts'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      totalCompletedBookings: data['totalCompletedBookings'] as int? ?? 0,
      currentMonthBookings: data['currentMonthBookings'] as int? ?? 0,
      currentMonthEarnings: data['currentMonthEarnings'] as int? ?? 0,
      totalEarningsTracked: data['totalEarningsTracked'] as int? ?? 0,
      totalCancellationsByProvider: data['totalCancellationsByProvider'] as int? ?? 0,
      lastCancelledAt: data['lastCancelledAt'] as Timestamp?,
      availabilitySummary: data['availabilitySummary'] as String?,
      nextAvailableDate: data['nextAvailableDate'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      schemaVersion: data['schemaVersion'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'serviceCategory': serviceCategory,
        'services': [serviceCategory],
        'skills': skills,
        'languages': languages,
        'fullTimeRate': fullTimeRate,
        'partTimeRate': partTimeRate,
        'experienceYears': experienceYears,
        'experienceLevel': experienceLevel,
        'bio': bio,
        'portfolioPhotos': portfolioPhotos,
        'portfolioCount': portfolioCount,
        'isVerified': isVerified,
        'verificationStatus': verificationStatus,
        'verifiedAt': verifiedAt,
        'verificationDocuments': verificationDocuments,
        'verificationRejectionReason': verificationRejectionReason,
        'verificationAttempts': verificationAttempts,
        'rating': rating,
        'totalReviews': totalReviews,
        'totalCompletedBookings': totalCompletedBookings,
        'currentMonthBookings': currentMonthBookings,
        'currentMonthEarnings': currentMonthEarnings,
        'totalEarningsTracked': totalEarningsTracked,
        'totalCancellationsByProvider': totalCancellationsByProvider,
        'lastCancelledAt': lastCancelledAt,
        'availabilitySummary': availabilitySummary,
        'nextAvailableDate': nextAvailableDate,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'schemaVersion': schemaVersion,
      };

  ProviderProfileModel copyWith({
    String? uid, String? serviceCategory, List<String>? skills,
    List<String>? languages, int? fullTimeRate, int? partTimeRate,
    int? experienceYears, String? experienceLevel, String? bio,
    List<String>? portfolioPhotos, int? portfolioCount, bool? isVerified,
    String? verificationStatus, Timestamp? verifiedAt,
    Map<String, dynamic>? verificationDocuments,
    String? verificationRejectionReason, int? verificationAttempts,
    double? rating, int? totalReviews, int? totalCompletedBookings,
    int? currentMonthBookings, int? currentMonthEarnings,
    int? totalEarningsTracked, int? totalCancellationsByProvider,
    Timestamp? lastCancelledAt, String? availabilitySummary,
    Timestamp? nextAvailableDate, Timestamp? createdAt,
    Timestamp? updatedAt, int? schemaVersion,
  }) =>
      ProviderProfileModel(
        uid: uid ?? this.uid,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        skills: skills ?? this.skills,
        languages: languages ?? this.languages,
        fullTimeRate: fullTimeRate ?? this.fullTimeRate,
        partTimeRate: partTimeRate ?? this.partTimeRate,
        experienceYears: experienceYears ?? this.experienceYears,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        bio: bio ?? this.bio,
        portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
        portfolioCount: portfolioCount ?? this.portfolioCount,
        isVerified: isVerified ?? this.isVerified,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        verifiedAt: verifiedAt ?? this.verifiedAt,
        verificationDocuments: verificationDocuments ?? this.verificationDocuments,
        verificationRejectionReason: verificationRejectionReason ?? this.verificationRejectionReason,
        verificationAttempts: verificationAttempts ?? this.verificationAttempts,
        rating: rating ?? this.rating,
        totalReviews: totalReviews ?? this.totalReviews,
        totalCompletedBookings: totalCompletedBookings ?? this.totalCompletedBookings,
        currentMonthBookings: currentMonthBookings ?? this.currentMonthBookings,
        currentMonthEarnings: currentMonthEarnings ?? this.currentMonthEarnings,
        totalEarningsTracked: totalEarningsTracked ?? this.totalEarningsTracked,
        totalCancellationsByProvider: totalCancellationsByProvider ?? this.totalCancellationsByProvider,
        lastCancelledAt: lastCancelledAt ?? this.lastCancelledAt,
        availabilitySummary: availabilitySummary ?? this.availabilitySummary,
        nextAvailableDate: nextAvailableDate ?? this.nextAvailableDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  @override
  List<Object?> get props => [
        uid, serviceCategory, skills, languages, fullTimeRate, partTimeRate,
        experienceYears, experienceLevel, bio, portfolioPhotos, portfolioCount,
        isVerified, verificationStatus, verifiedAt, verificationDocuments,
        verificationRejectionReason, verificationAttempts, rating, totalReviews,
        totalCompletedBookings, currentMonthBookings, currentMonthEarnings,
        totalEarningsTracked, totalCancellationsByProvider, lastCancelledAt,
        availabilitySummary, nextAvailableDate, createdAt, updatedAt, schemaVersion,
      ];
}
