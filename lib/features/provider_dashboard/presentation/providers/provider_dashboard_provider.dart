import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../bookings/presentation/providers/booking_flow_provider.dart';

part 'provider_dashboard_provider.g.dart';

class ProviderDashboardState {
  final List<BookingModel> pendingRequests;
  final List<BookingModel> recentBookings;
  final bool isLoading;
  final String? error;

  const ProviderDashboardState({
    this.pendingRequests = const [],
    this.recentBookings = const [],
    this.isLoading = false,
    this.error,
  });

  ProviderDashboardState copyWith({
    List<BookingModel>? pendingRequests,
    List<BookingModel>? recentBookings,
    bool? isLoading,
    String? error,
  }) =>
      ProviderDashboardState(
        pendingRequests: pendingRequests ?? this.pendingRequests,
        recentBookings: recentBookings ?? this.recentBookings,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

@riverpod
class ProviderDashboard extends _$ProviderDashboard {
  @override
  Stream<ProviderDashboardState> build() async* {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
    if (uid == null) {
      yield const ProviderDashboardState();
      return;
    }

    final repo = ref.read(bookingsRepositoryProvider);

    yield const ProviderDashboardState(isLoading: true);

    // Listen to pending bookings stream
    await for (final pending in repo.getProviderBookings(uid, status: 'pending')) {
      // For recent bookings, do a one-time fetch of the last 5 non-pending ones
      List<BookingModel> recent = [];
      try {
        final confirmedStream = repo.getProviderBookings(uid, status: 'confirmed');
        await for (final c in confirmedStream) {
          recent = c.take(5).toList();
          break;
        }
      } catch (_) {}

      yield ProviderDashboardState(
        pendingRequests: pending.take(3).toList(),
        recentBookings: recent,
        isLoading: false,
      );
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    final repo = ref.read(bookingsRepositoryProvider);
    await repo.updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'confirmed',
    );
  }

  Future<void> rejectBooking(String bookingId, String reasonCode) async {
    final repo = ref.read(bookingsRepositoryProvider);
    await repo.updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'rejected',
      rejectionReasonCode: reasonCode,
    );
  }
}

// ── Pending count stream for badge ───────────────────────────────────────────
@riverpod
Stream<int> providerPendingCount(ProviderPendingCountRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(0);
  final repo = ref.read(bookingsRepositoryProvider);
  return repo.getProviderBookings(uid, status: 'pending').map((list) => list.length);
}
