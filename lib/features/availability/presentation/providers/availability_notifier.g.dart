// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityRepositoryHash() =>
    r'1dd6ecb7063b654a092383c4c3b97a29682f0ff9';

/// See also [availabilityRepository].
@ProviderFor(availabilityRepository)
final availabilityRepositoryProvider =
    AutoDisposeProvider<AvailabilityRepository>.internal(
  availabilityRepository,
  name: r'availabilityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availabilityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailabilityRepositoryRef
    = AutoDisposeProviderRef<AvailabilityRepository>;
String _$availabilityNotifierHash() =>
    r'9b63b8b9d62cd520bcdbe326b8811df7ea65136e';

/// See also [AvailabilityNotifier].
@ProviderFor(AvailabilityNotifier)
final availabilityNotifierProvider = AutoDisposeNotifierProvider<
    AvailabilityNotifier, AvailabilityState>.internal(
  AvailabilityNotifier.new,
  name: r'availabilityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availabilityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvailabilityNotifier = AutoDisposeNotifier<AvailabilityState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
