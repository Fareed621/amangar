// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingsRepositoryHash() =>
    r'82b9c37a03e1c12ebe058cdbf0120bcc592904be';

/// See also [bookingsRepository].
@ProviderFor(bookingsRepository)
final bookingsRepositoryProvider =
    AutoDisposeProvider<BookingsRepository>.internal(
  bookingsRepository,
  name: r'bookingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingsRepositoryRef = AutoDisposeProviderRef<BookingsRepository>;
String _$bookingFlowHash() => r'5f1335bc89fcdbc12947a35dfa0bae943eb41693';

/// See also [BookingFlow].
@ProviderFor(BookingFlow)
final bookingFlowProvider =
    AutoDisposeNotifierProvider<BookingFlow, BookingFlowState>.internal(
  BookingFlow.new,
  name: r'bookingFlowProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bookingFlowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingFlow = AutoDisposeNotifier<BookingFlowState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
