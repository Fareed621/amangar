import '../../../../core/models/booking_model.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_with_profile_model.dart';

abstract class HirerDashboardRepository {
  Future<List<BookingModel>> getRecentBookings(String hirerId, {int limit = 5});
  Future<List<FavoriteModel>> getFavorites(String hirerId, {int limit = 5});
  Future<List<ProviderWithProfileModel>> getRecommendedProviders(String city, String? category, {int limit = 10});
}
