import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/booking_model.dart';
import '../domain/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createBooking(BookingModel booking) async {
    final docRef = _firestore.collection('bookings').doc();
    final newBooking = booking.copyWith(
      id: docRef.id,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    await docRef.set(newBooking.toFirestore());
    return docRef.id;
  }

  @override
  Stream<List<BookingModel>> getHirerBookings(String hirerId, {required bool upcoming}) {
    Query query = _firestore.collection('bookings').where('hirerId', isEqualTo: hirerId);
    if (upcoming) {
      query = query.where('status', whereIn: ['pending', 'confirmed', 'in_progress']);
    } else {
      query = query.where('status', whereIn: ['completed', 'cancelled', 'rejected']);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? Timestamp.now()) ?? 0);
      return list;
    });
  }

  @override
  Stream<List<BookingModel>> getProviderBookings(String providerId, {required String status}) {
    Query query = _firestore.collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: status);
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? Timestamp.now()) ?? 0);
      return list;
    });
  }

  @override
  Stream<BookingModel?> getBookingById(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map((doc) {
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationReasonCode,
    String? completedBy,
    String? rejectionReasonCode,
  }) async {
    final updates = <String, dynamic>{
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    };
    if (newStatus == 'cancelled') {
      updates['cancelledBy'] = cancelledBy;
      updates['cancellationReason'] = cancellationReason;
      updates['cancellationReasonCode'] = cancellationReasonCode;
      updates['cancelledAt'] = Timestamp.now();
    } else if (newStatus == 'completed') {
      updates['completedBy'] = completedBy;
      updates['completedAt'] = Timestamp.now();
    } else if (newStatus == 'rejected') {
      updates['cancellationReasonCode'] = rejectionReasonCode;
    }
    await _firestore.collection('bookings').doc(bookingId).update(updates);

    // When booking is confirmed, record earnings for the provider
    if (newStatus == 'confirmed') {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final data = bookingDoc.data()!;
        final providerId = data['providerId'] as String?;
        final displayPrice = data['displayPrice'] as int? ?? 0;
        final hirerName = data['hirerName'] as String?;
        final serviceCategory = data['serviceCategory'] as String? ?? '';
        final serviceType = data['serviceType'] as String? ?? 'full_time';
        final dates = data['dates'] as List<dynamic>? ?? [];
        final bookingDate = dates.isNotEmpty ? dates.first as Timestamp? : null;

        if (providerId != null && displayPrice > 0) {
          final batch = _firestore.batch();

          // 1. Write credit ledger entry
          final ledgerRef = _firestore
              .collection('users')
              .doc(providerId)
              .collection('earningsLedger')
              .doc();
          batch.set(ledgerRef, {
            'bookingId': bookingId,
            'hirerName': hirerName,
            'serviceCategory': serviceCategory,
            'serviceType': serviceType,
            'amount': displayPrice,
            'entryType': 'credit',
            'bookingDate': bookingDate,
            'createdAt': Timestamp.now(),
          });

          // 2. Increment provider profile earnings stats
          final profileRef = _firestore.doc('users/$providerId/providerProfile/profile');
          batch.update(profileRef, {
            'totalEarningsTracked': FieldValue.increment(displayPrice),
            'currentMonthEarnings': FieldValue.increment(displayPrice),
            'totalCompletedBookings': FieldValue.increment(0), // incremented on complete
            'currentMonthBookings': FieldValue.increment(1),
          });

          await batch.commit();
        }
      }
    }
  }

  @override
  Future<void> confirmPayment(String bookingId, String uid, {bool status = true}) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'hirerConfirmedPayment': status,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> confirmReceipt(String bookingId, String uid, {bool status = true}) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'providerConfirmedReceipt': status,
      'updatedAt': Timestamp.now(),
    });
  }
}
