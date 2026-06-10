import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/favorites_repository_impl.dart';
import '../../domain/favorites_repository.dart';

part 'favorites_provider.g.dart';

@riverpod
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) {
  return FavoritesRepositoryImpl();
}

@riverpod
Stream<List<FavoriteModel>> favorites(FavoritesRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return ref.read(favoritesRepositoryProvider).getFavorites(uid);
}

@riverpod
Future<bool> isFavorite(IsFavoriteRef ref, String providerId) async {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return false;
  return ref.read(favoritesRepositoryProvider).isFavorite(uid, providerId);
}

@riverpod
class FavoriteToggle extends _$FavoriteToggle {
  @override
  bool build(String providerId) => false; // isLoading

  Future<void> toggle({
    required UserModel provider,
    required ProviderProfileModel profile,
    required bool currentlyFavorited,
  }) async {
    state = true;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) {
      state = false;
      return;
    }
    
    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (currentlyFavorited) {
        await repo.removeFavorite(uid, provider.uid);
      } else {
        await repo.addFavorite(uid, provider, profile);
      }
      ref.invalidate(isFavoriteProvider(provider.uid));
      ref.invalidate(favoritesProvider);
    } catch (_) {
      // Errors handled by UI
    } finally {
      state = false;
    }
  }
}
