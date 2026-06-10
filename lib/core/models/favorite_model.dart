// lib/core/models/favorite_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FavoriteModel extends Equatable {
  const FavoriteModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    this.providerPhoto,
    required this.serviceCategory,
    required this.city,
    required this.rating,
    required this.fullTimeRate,
    required this.partTimeRate,
    required this.isVerified,
    this.addedAt,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String? providerPhoto;
  final String serviceCategory;
  final String city;
  final double rating;
  final int fullTimeRate;
  final int partTimeRate;
  final bool isVerified;
  final Timestamp? addedAt;

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteModel(
      id: doc.id,
      providerId: data['providerId'] as String? ?? doc.id,
      providerName: data['providerName'] as String? ?? '',
      providerPhoto: data['providerPhoto'] as String?,
      serviceCategory: data['serviceCategory'] as String? ?? '',
      city: data['city'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      fullTimeRate: data['fullTimeRate'] as int? ?? 0,
      partTimeRate: data['partTimeRate'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      addedAt: data['addedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'providerId': providerId,
        'providerName': providerName,
        'providerPhoto': providerPhoto,
        'serviceCategory': serviceCategory,
        'city': city,
        'rating': rating,
        'fullTimeRate': fullTimeRate,
        'partTimeRate': partTimeRate,
        'isVerified': isVerified,
        'addedAt': addedAt,
      };

  FavoriteModel copyWith({
    String? id, String? providerId, String? providerName,
    String? providerPhoto, String? serviceCategory, String? city,
    double? rating, int? fullTimeRate, int? partTimeRate,
    bool? isVerified, Timestamp? addedAt,
  }) =>
      FavoriteModel(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        providerPhoto: providerPhoto ?? this.providerPhoto,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        city: city ?? this.city,
        rating: rating ?? this.rating,
        fullTimeRate: fullTimeRate ?? this.fullTimeRate,
        partTimeRate: partTimeRate ?? this.partTimeRate,
        isVerified: isVerified ?? this.isVerified,
        addedAt: addedAt ?? this.addedAt,
      );

  @override
  List<Object?> get props => [
        id, providerId, providerName, providerPhoto, serviceCategory,
        city, rating, fullTimeRate, partTimeRate, isVerified, addedAt,
      ];
}
