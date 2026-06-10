import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_profile_model.dart';
import '../../../../core/models/user_model.dart';

abstract class FavoritesRepository {
  Stream<List<FavoriteModel>> getFavorites(String hirerId);
  Future<bool> isFavorite(String hirerId, String providerId);
  Future<void> addFavorite(String hirerId, UserModel provider, ProviderProfileModel profile);
  Future<void> removeFavorite(String hirerId, String providerId);
}
