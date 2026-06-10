import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/provider_profile_model.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/models/rating_model.dart';
import '../../../../core/models/user_model.dart';
import '../domain/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
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
  }) async {
    Query usersQuery = _firestore.collection(FirestorePaths.users);

    // Base filters
    usersQuery = usersQuery
        .where('role', isEqualTo: 'provider')
        .where('isBanned', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .where('onboardingComplete', isEqualTo: true);

    // Exact matches
    if (city != null && city.isNotEmpty) {
      usersQuery = usersQuery.where('city', isEqualTo: city);
    }
    if (serviceCategory != null && serviceCategory.isNotEmpty) {
      usersQuery = usersQuery.where('serviceCategory', isEqualTo: serviceCategory);
    }
    if (verifiedOnly) {
      usersQuery = usersQuery.where('isVerified', isEqualTo: true);
    }
    if (minRating > 0) {
      usersQuery = usersQuery.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    // Sort - REMOVED from Firestore to avoid composite index requirement
    // Pagination
    if (startAfter != null) {
      usersQuery = usersQuery.startAfterDocument(startAfter);
    }

    usersQuery = usersQuery.limit(limit);

    final snapshot = await usersQuery.get();

    final futures = snapshot.docs.map((doc) async {
      final user = UserModel.fromFirestore(doc);
      
      // Filter by query (Name matching is done client-side due to Firestore limits)
      if (query != null && query.isNotEmpty) {
        if (!user.name.toLowerCase().contains(query.toLowerCase())) {
          return null; // Skip this user
        }
      }

      final profileSnapshot = await _firestore.doc(FirestorePaths.providerProfile(user.uid)).get();

      if (!profileSnapshot.exists) return null;

      final profile = ProviderProfileModel.fromFirestore(profileSnapshot);

      // Client-side filtering for sub-collection properties
      if (experienceLevels.isNotEmpty && !experienceLevels.contains(profile.experienceLevel)) {
        return null;
      }
      if (availabilityType == 'full_time' && profile.fullTimeRate == 0) return null;
      if (availabilityType == 'part_time' && profile.partTimeRate == 0) return null;
      
      // Price filters
      if (minPrice != null) {
        if (profile.fullTimeRate < minPrice && profile.partTimeRate < minPrice) return null;
      }
      if (maxPrice != null) {
        if (profile.fullTimeRate > maxPrice && profile.partTimeRate > maxPrice) return null;
      }

      return ProviderWithProfileModel(user: user, profile: profile);
    }).toList();

    final results = await Future.wait(futures);
    final validResults = results.whereType<ProviderWithProfileModel>().toList();

    // Client-side sort
    validResults.sort((a, b) {
      if (sortBy == 'reviews_desc') {
        return b.user.totalReviews.compareTo(a.user.totalReviews);
      }
      return b.user.rating.compareTo(a.user.rating);
    });

    return validResults;
  }

  @override
  Future<ProviderWithProfileModel?> getProviderWithProfile(String uid) async {
    final userSnap = await _firestore.doc(FirestorePaths.user(uid)).get();
    if (!userSnap.exists) return null;

    final profileSnap = await _firestore.doc(FirestorePaths.providerProfile(uid)).get();
        
    if (!profileSnap.exists) return null;

    return ProviderWithProfileModel(
      user: UserModel.fromFirestore(userSnap),
      profile: ProviderProfileModel.fromFirestore(profileSnap),
    );
  }

  @override
  Future<List<RatingModel>> getProviderRatings(String providerId, {DocumentSnapshot? startAfter}) async {
    Query query = _firestore.collection('ratings')
        .where('toUserId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .limit(10);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    return snap.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<bool> hasRatedBooking(String fromUserId, String bookingId) async {
    final snap = await _firestore.collection('ratings')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
