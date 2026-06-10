// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityRepositoryHash() =>
    r'611e990a0a07208b496c1842af08e7239e06be0c';

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
String _$weeklyTemplateHash() => r'ab0c2aa7da0b36e81b5da093acec3f34e2305dc4';

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

/// See also [weeklyTemplate].
@ProviderFor(weeklyTemplate)
const weeklyTemplateProvider = WeeklyTemplateFamily();

/// See also [weeklyTemplate].
class WeeklyTemplateFamily extends Family<AsyncValue<WeeklyTemplateModel?>> {
  /// See also [weeklyTemplate].
  const WeeklyTemplateFamily();

  /// See also [weeklyTemplate].
  WeeklyTemplateProvider call(
    String uid,
  ) {
    return WeeklyTemplateProvider(
      uid,
    );
  }

  @override
  WeeklyTemplateProvider getProviderOverride(
    covariant WeeklyTemplateProvider provider,
  ) {
    return call(
      provider.uid,
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
  String? get name => r'weeklyTemplateProvider';
}

/// See also [weeklyTemplate].
class WeeklyTemplateProvider
    extends AutoDisposeFutureProvider<WeeklyTemplateModel?> {
  /// See also [weeklyTemplate].
  WeeklyTemplateProvider(
    String uid,
  ) : this._internal(
          (ref) => weeklyTemplate(
            ref as WeeklyTemplateRef,
            uid,
          ),
          from: weeklyTemplateProvider,
          name: r'weeklyTemplateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weeklyTemplateHash,
          dependencies: WeeklyTemplateFamily._dependencies,
          allTransitiveDependencies:
              WeeklyTemplateFamily._allTransitiveDependencies,
          uid: uid,
        );

  WeeklyTemplateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<WeeklyTemplateModel?> Function(WeeklyTemplateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyTemplateProvider._internal(
        (ref) => create(ref as WeeklyTemplateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WeeklyTemplateModel?> createElement() {
    return _WeeklyTemplateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyTemplateProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeeklyTemplateRef on AutoDisposeFutureProviderRef<WeeklyTemplateModel?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _WeeklyTemplateProviderElement
    extends AutoDisposeFutureProviderElement<WeeklyTemplateModel?>
    with WeeklyTemplateRef {
  _WeeklyTemplateProviderElement(super.provider);

  @override
  String get uid => (origin as WeeklyTemplateProvider).uid;
}

String _$unavailableDatesHash() => r'451ab76958040a7484c4804019eb7edc90c4c2fa';

/// See also [unavailableDates].
@ProviderFor(unavailableDates)
const unavailableDatesProvider = UnavailableDatesFamily();

/// See also [unavailableDates].
class UnavailableDatesFamily extends Family<AsyncValue<Set<DateTime>>> {
  /// See also [unavailableDates].
  const UnavailableDatesFamily();

  /// See also [unavailableDates].
  UnavailableDatesProvider call(
    String providerId,
    DateTime startMonth,
    DateTime endMonth,
  ) {
    return UnavailableDatesProvider(
      providerId,
      startMonth,
      endMonth,
    );
  }

  @override
  UnavailableDatesProvider getProviderOverride(
    covariant UnavailableDatesProvider provider,
  ) {
    return call(
      provider.providerId,
      provider.startMonth,
      provider.endMonth,
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
  String? get name => r'unavailableDatesProvider';
}

/// See also [unavailableDates].
class UnavailableDatesProvider
    extends AutoDisposeFutureProvider<Set<DateTime>> {
  /// See also [unavailableDates].
  UnavailableDatesProvider(
    String providerId,
    DateTime startMonth,
    DateTime endMonth,
  ) : this._internal(
          (ref) => unavailableDates(
            ref as UnavailableDatesRef,
            providerId,
            startMonth,
            endMonth,
          ),
          from: unavailableDatesProvider,
          name: r'unavailableDatesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unavailableDatesHash,
          dependencies: UnavailableDatesFamily._dependencies,
          allTransitiveDependencies:
              UnavailableDatesFamily._allTransitiveDependencies,
          providerId: providerId,
          startMonth: startMonth,
          endMonth: endMonth,
        );

  UnavailableDatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.providerId,
    required this.startMonth,
    required this.endMonth,
  }) : super.internal();

  final String providerId;
  final DateTime startMonth;
  final DateTime endMonth;

  @override
  Override overrideWith(
    FutureOr<Set<DateTime>> Function(UnavailableDatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnavailableDatesProvider._internal(
        (ref) => create(ref as UnavailableDatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        providerId: providerId,
        startMonth: startMonth,
        endMonth: endMonth,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Set<DateTime>> createElement() {
    return _UnavailableDatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnavailableDatesProvider &&
        other.providerId == providerId &&
        other.startMonth == startMonth &&
        other.endMonth == endMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, providerId.hashCode);
    hash = _SystemHash.combine(hash, startMonth.hashCode);
    hash = _SystemHash.combine(hash, endMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnavailableDatesRef on AutoDisposeFutureProviderRef<Set<DateTime>> {
  /// The parameter `providerId` of this provider.
  String get providerId;

  /// The parameter `startMonth` of this provider.
  DateTime get startMonth;

  /// The parameter `endMonth` of this provider.
  DateTime get endMonth;
}

class _UnavailableDatesProviderElement
    extends AutoDisposeFutureProviderElement<Set<DateTime>>
    with UnavailableDatesRef {
  _UnavailableDatesProviderElement(super.provider);

  @override
  String get providerId => (origin as UnavailableDatesProvider).providerId;
  @override
  DateTime get startMonth => (origin as UnavailableDatesProvider).startMonth;
  @override
  DateTime get endMonth => (origin as UnavailableDatesProvider).endMonth;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
