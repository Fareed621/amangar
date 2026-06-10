import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/rating_model.dart';
import '../domain/ratings_repository.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> submitRating(RatingModel rating) async {
    final docRef = _firestore.collection('ratings').doc();
    final newRating = rating.copyWith(
      id: docRef.id,
      createdAt: Timestamp.now(),
    );
    await docRef.set(newRating.toFirestore());

    // We need to fetch booking to know the role
    final bookingDoc = await _firestore.collection('bookings').doc(rating.bookingId).get();
    if (bookingDoc.exists) {
      final hirerId = bookingDoc.data()?['hirerId'] as String?;
      final providerId = bookingDoc.data()?['providerId'] as String?;

      if (hirerId == rating.fromUserId) {
        // Hirer rated the provider — mark on booking and update provider aggregate
        await _firestore.collection('bookings').doc(rating.bookingId).update({
          'hirerRated': true,
          'hirerRatingId': docRef.id,
        });

        // Update provider's aggregate rating via transaction
        if (providerId != null) {
          final profileRef = _firestore.doc('users/$providerId/providerProfile/profile');
          await _firestore.runTransaction((txn) async {
            final profileSnap = await txn.get(profileRef);
            final currentRating = (profileSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
            final currentReviews = profileSnap.data()?['totalReviews'] as int? ?? 0;
            final newTotal = currentReviews + 1;
            final newAvg = ((currentRating * currentReviews) + rating.rating) / newTotal;
            txn.update(profileRef, {
              'rating': double.parse(newAvg.toStringAsFixed(2)),
              'totalReviews': newTotal,
            });
          });
        }
      } else {
        await _firestore.collection('bookings').doc(rating.bookingId).update({
          'providerRated': true,
          'providerRatingId': docRef.id,
        });
      }
    }

    return docRef.id;
  }

  @override
  Stream<List<RatingModel>> getProviderRatings(String providerId) {
    return _firestore
        .collection('ratings')
        .where('toUserId', isEqualTo: providerId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RatingModel.fromFirestore(d)).toList());
  }

  @override
  Future<bool> hasRatedBooking(String bookingId, String raterId) async {
    final snap = await _firestore
        .collection('ratings')
        .where('bookingId', isEqualTo: bookingId)
        .where('fromUserId', isEqualTo: raterId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
