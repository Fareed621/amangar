// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_bookings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$providerBookingsHash() => r'9e6ec6117e57372370843e8cf1ddddddf37de990';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [providerBookings].
@ProviderFor(providerBookings)
const providerBookingsProvider = ProviderBookingsFamily();

/// See also [providerBookings].
class ProviderBookingsFamily extends Family<AsyncValue<List<BookingModel>>> {
  /// See also [providerBookings].
  const ProviderBookingsFamily();

  /// See also [providerBookings].
  ProviderBookingsProvider call(
    String status,
  ) {
    return ProviderBookingsProvider(
      status,
    );
  }

  @override
  ProviderBookingsProvider getProviderOverride(
    covariant ProviderBookingsProvider provider,
  ) {
    return call(
      provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'providerBookingsProvider';
}

/// See also [providerBookings].
class ProviderBookingsProvider
    extends AutoDisposeStreamProvider<List<BookingModel>> {
  /// See also [providerBookings].
  ProviderBookingsProvider(
    String status,
  ) : this._internal(
          (ref) => providerBookings(
            ref as ProviderBookingsRef,
            status,
          ),
          from: providerBookingsProvider,
          name: r'providerBookingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$providerBookingsHash,
          dependencies: ProviderBookingsFamily._dependencies,
          allTransitiveDependencies:
              ProviderBookingsFamily._allTransitiveDependencies,
          status: status,
        );

  ProviderBookingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    Stream<List<BookingModel>> Function(ProviderBookingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProviderBookingsProvider._internal(
        (ref) => create(ref as ProviderBookingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BookingModel>> createElement() {
    return _ProviderBookingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderBookingsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProviderBookingsRef on AutoDisposeStreamProviderRef<List<BookingModel>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _ProviderBookingsProviderElement
    extends AutoDisposeStreamProviderElement<List<BookingModel>>
    with ProviderBookingsRef {
  _ProviderBookingsProviderElement(super.provider);

  @override
  String get status => (origin as ProviderBookingsProvider).status;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
