import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/models/rating_model.dart';

abstract class SearchRepository {
  Future<List<ProviderWithProfileModel>> searchProviders({
    String? query,
    String? city,
    String? serviceCategory,
    double minRating = 0.0,
    List<String> experienceLevels = const [],
    String availabilityType = 'both',
    bool verifiedOnly = false,
    int? minPrice,
    int? maxPrice,
    String sortBy = 'rating_desc',
    DocumentSnapshot? startAfter,
    int limit = 10,
  });

  Future<ProviderWithProfileModel?> getProviderWithProfile(String uid);

  Future<List<RatingModel>> getProviderRatings(String providerId, {DocumentSnapshot? startAfter});

  Future<bool> hasRatedBooking(String fromUserId, String bookingId);
}
