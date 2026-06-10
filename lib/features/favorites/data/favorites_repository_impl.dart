import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../domain/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FavoriteModel>> getFavorites(String hirerId) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(hirerId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList());
  }

  @override
  Future<bool> isFavorite(String hirerId, String providerId) async {
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(hirerId)
        .collection('favorites')
        .doc(providerId)
        .get();
    return doc.exists;
  }

  @override
  Future<void> addFavorite(String hirerId, UserModel provider, ProviderProfileModel profile) async {
    final collRef = _firestore
        .collection(FirestorePaths.users)
        .doc(hirerId)
        .collection('favorites');

    final snap = await collRef.count().get();
    if (snap.count != null && snap.count! >= 10) {
      throw const AppException('You can only have up to 10 favorites.');
    }

    final favorite = FavoriteModel(
      id: provider.uid,
      providerId: provider.uid,
      providerName: provider.name,
      providerPhoto: provider.profilePhoto,
      city: provider.city ?? 'Unknown',
      serviceCategory: provider.serviceCategory ?? '',
      rating: provider.rating,
      fullTimeRate: profile.fullTimeRate,
      partTimeRate: profile.partTimeRate,
      isVerified: profile.isVerified,
      addedAt: Timestamp.now(),
    );

    await collRef.doc(provider.uid).set(favorite.toFirestore());
  }

  @override
  Future<void> removeFavorite(String hirerId, String providerId) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(hirerId)
        .collection('favorites')
        .doc(providerId)
        .delete();
  }
}
