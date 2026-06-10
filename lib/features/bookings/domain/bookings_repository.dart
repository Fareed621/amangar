import '../../../../core/models/booking_model.dart';

abstract class BookingsRepository {
  Future<String> createBooking(BookingModel booking);
  Stream<List<BookingModel>> getHirerBookings(
      String hirerId, {required bool upcoming});
  Stream<List<BookingModel>> getProviderBookings(
      String providerId, {required String status});
  Stream<BookingModel?> getBookingById(String bookingId);
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationReasonCode,
    String? completedBy,
    String? rejectionReasonCode,
  });
  Future<void> confirmPayment(String bookingId, String uid, {bool status = true});
  Future<void> confirmReceipt(String bookingId, String uid, {bool status = true});
}
