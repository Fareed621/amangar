import '../../../../core/models/rating_model.dart';

abstract class RatingsRepository {
  Future<String> submitRating(RatingModel rating);
  Stream<List<RatingModel>> getProviderRatings(String providerId);
  Future<bool> hasRatedBooking(String bookingId, String raterId);
}
