import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_profile_model.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../domain/hirer_dashboard_repository.dart';

class HirerDashboardRepositoryImpl implements HirerDashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<BookingModel>> getRecentBookings(String hirerId, {int limit = 5}) async {
    final snap = await _firestore
        .collection('bookings')
        .where('hirerId', isEqualTo: hirerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
        
    return snap.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<FavoriteModel>> getFavorites(String hirerId, {int limit = 5}) async {
    final snap = await _firestore
        .collection(FirestorePaths.users)
        .doc(hirerId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ProviderWithProfileModel>> getRecommendedProviders(
    String city, String? category, {int limit = 10}
  ) async {
    Query query = _firestore.collection(FirestorePaths.users)
        .where('role', isEqualTo: 'provider')
        .where('isBanned', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .where('onboardingComplete', isEqualTo: true);

    if (city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    
    // Sort removed to avoid composite index requirement
    query = query.limit(limit);

    final snap = await query.get();
    
    final futures = snap.docs.map((doc) async {
      final user = UserModel.fromFirestore(doc);
      
      // Client-side category filtering if provided
      if (category != null && category.isNotEmpty && user.serviceCategory != category) {
        return null;
      }

      final profileSnap = await _firestore.doc(FirestorePaths.providerProfile(user.uid)).get();

      if (!profileSnap.exists) return null;

      final profile = ProviderProfileModel.fromFirestore(profileSnap);
      return ProviderWithProfileModel(user: user, profile: profile);
    });

    final results = await Future.wait(futures);
    final validResults = results.whereType<ProviderWithProfileModel>().toList();
    
    validResults.sort((a, b) => b.user.rating.compareTo(a.user.rating));
    return validResults;
  }
}
