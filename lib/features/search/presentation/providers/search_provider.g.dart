// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchRepositoryHash() => r'dce413b49a4764c078627c2e8fb043b5b44865f8';

/// See also [searchRepository].
@ProviderFor(searchRepository)
final searchRepositoryProvider = AutoDisposeProvider<SearchRepository>.internal(
  searchRepository,
  name: r'searchRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchRepositoryRef = AutoDisposeProviderRef<SearchRepository>;
String _$providerDetailHash() => r'36946bfa2df62763bc7561b282555fd127f6d443';

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

/// See also [providerDetail].
@ProviderFor(providerDetail)
const providerDetailProvider = ProviderDetailFamily();

/// See also [providerDetail].
class ProviderDetailFamily
    extends Family<AsyncValue<ProviderWithProfileModel?>> {
  /// See also [providerDetail].
  const ProviderDetailFamily();

  /// See also [providerDetail].
  ProviderDetailProvider call(
    String uid,
  ) {
    return ProviderDetailProvider(
      uid,
    );
  }

  @override
  ProviderDetailProvider getProviderOverride(
    covariant ProviderDetailProvider provider,
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
  String? get name => r'providerDetailProvider';
}

/// See also [providerDetail].
class ProviderDetailProvider
    extends AutoDisposeFutureProvider<ProviderWithProfileModel?> {
  /// See also [providerDetail].
  ProviderDetailProvider(
    String uid,
  ) : this._internal(
          (ref) => providerDetail(
            ref as ProviderDetailRef,
            uid,
          ),
          from: providerDetailProvider,
          name: r'providerDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$providerDetailHash,
          dependencies: ProviderDetailFamily._dependencies,
          allTransitiveDependencies:
              ProviderDetailFamily._allTransitiveDependencies,
          uid: uid,
        );

  ProviderDetailProvider._internal(
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
    FutureOr<ProviderWithProfileModel?> Function(ProviderDetailRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProviderDetailProvider._internal(
        (ref) => create(ref as ProviderDetailRef),
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
  AutoDisposeFutureProviderElement<ProviderWithProfileModel?> createElement() {
    return _ProviderDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderDetailProvider && other.uid == uid;
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
mixin ProviderDetailRef
    on AutoDisposeFutureProviderRef<ProviderWithProfileModel?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _ProviderDetailProviderElement
    extends AutoDisposeFutureProviderElement<ProviderWithProfileModel?>
    with ProviderDetailRef {
  _ProviderDetailProviderElement(super.provider);

  @override
  String get uid => (origin as ProviderDetailProvider).uid;
}

String _$searchFilterHash() => r'8b1cb4ad490faf11f35a828841f67d5fedf85809';

/// See also [SearchFilter].
@ProviderFor(SearchFilter)
final searchFilterProvider =
    NotifierProvider<SearchFilter, SearchFilterModel>.internal(
  SearchFilter.new,
  name: r'searchFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchFilter = Notifier<SearchFilterModel>;
String _$searchResultsHash() => r'87e0b2482a454cc08dbcef022186f76d848deb68';

/// See also [SearchResults].
@ProviderFor(SearchResults)
final searchResultsProvider = AsyncNotifierProvider<SearchResults,
    List<ProviderWithProfileModel>>.internal(
  SearchResults.new,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchResults = AsyncNotifier<List<ProviderWithProfileModel>>;
String _$providerRatingsHash() => r'473bf165c841e841d0497343c03835ec29c6013e';

abstract class _$ProviderRatings
    extends BuildlessAutoDisposeAsyncNotifier<List<RatingModel>> {
  late final String providerId;

  FutureOr<List<RatingModel>> build(
    String providerId,
  );
}

/// See also [ProviderRatings].
@ProviderFor(ProviderRatings)
const providerRatingsProvider = ProviderRatingsFamily();

/// See also [ProviderRatings].
class ProviderRatingsFamily extends Family<AsyncValue<List<RatingModel>>> {
  /// See also [ProviderRatings].
  const ProviderRatingsFamily();

  /// See also [ProviderRatings].
  ProviderRatingsProvider call(
    String providerId,
  ) {
    return ProviderRatingsProvider(
      providerId,
    );
  }

  @override
  ProviderRatingsProvider getProviderOverride(
    covariant ProviderRatingsProvider provider,
  ) {
    return call(
      provider.providerId,
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
  String? get name => r'providerRatingsProvider';
}

/// See also [ProviderRatings].
class ProviderRatingsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProviderRatings, List<RatingModel>> {
  /// See also [ProviderRatings].
  ProviderRatingsProvider(
    String providerId,
  ) : this._internal(
          () => ProviderRatings()..providerId = providerId,
          from: providerRatingsProvider,
          name: r'providerRatingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$providerRatingsHash,
          dependencies: ProviderRatingsFamily._dependencies,
          allTransitiveDependencies:
              ProviderRatingsFamily._allTransitiveDependencies,
          providerId: providerId,
        );

  ProviderRatingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.providerId,
  }) : super.internal();

  final String providerId;

  @override
  FutureOr<List<RatingModel>> runNotifierBuild(
    covariant ProviderRatings notifier,
  ) {
    return notifier.build(
      providerId,
    );
  }

  @override
  Override overrideWith(ProviderRatings Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProviderRatingsProvider._internal(
        () => create()..providerId = providerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        providerId: providerId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProviderRatings, List<RatingModel>>
      createElement() {
    return _ProviderRatingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderRatingsProvider && other.providerId == providerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, providerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProviderRatingsRef
    on AutoDisposeAsyncNotifierProviderRef<List<RatingModel>> {
  /// The parameter `providerId` of this provider.
  String get providerId;
}

class _ProviderRatingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProviderRatings,
        List<RatingModel>> with ProviderRatingsRef {
  _ProviderRatingsProviderElement(super.provider);

  @override
  String get providerId => (origin as ProviderRatingsProvider).providerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
