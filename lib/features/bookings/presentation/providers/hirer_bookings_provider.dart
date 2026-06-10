import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/providers/auth_provider.dart';
import 'booking_flow_provider.dart';

part 'hirer_bookings_provider.g.dart';

@riverpod
Stream<List<BookingModel>> hirerUpcomingBookings(HirerUpcomingBookingsRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.read(bookingsRepositoryProvider).getHirerBookings(user.uid, upcoming: true);
}

@riverpod
Stream<List<BookingModel>> hirerPastBookings(HirerPastBookingsRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.read(bookingsRepositoryProvider).getHirerBookings(user.uid, upcoming: false);
}
