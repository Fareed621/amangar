import 'package:equatable/equatable.dart';

class SearchFilterModel extends Equatable {
  const SearchFilterModel({
    this.query = '',
    this.city,
    this.serviceCategory,
    this.minRating = 0.0,
    this.experienceLevels = const [],
    this.availabilityType = 'both',
    this.verifiedOnly = false,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'rating_desc',
  });

  final String query;
  final String? city;
  final String? serviceCategory;
  final double minRating;
  final List<String> experienceLevels;
  final String availabilityType;
  final bool verifiedOnly;
  final int? minPrice;
  final int? maxPrice;
  final String sortBy;

  SearchFilterModel copyWith({
    String? query,
    String? city,
    String? serviceCategory,
    double? minRating,
    List<String>? experienceLevels,
    String? availabilityType,
    bool? verifiedOnly,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
  }) {
    return SearchFilterModel(
      query: query ?? this.query,
      city: city ?? this.city,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      minRating: minRating ?? this.minRating,
      experienceLevels: experienceLevels ?? this.experienceLevels,
      availabilityType: availabilityType ?? this.availabilityType,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        query,
        city,
        serviceCategory,
        minRating,
        experienceLevels,
        availabilityType,
        verifiedOnly,
        minPrice,
        maxPrice,
        sortBy,
      ];
}
