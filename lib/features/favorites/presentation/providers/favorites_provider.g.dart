// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesRepositoryHash() =>
    r'0057435b0d5bc699bcc2189ef2e5895e9cc2cb06';

/// See also [favoritesRepository].
@ProviderFor(favoritesRepository)
final favoritesRepositoryProvider =
    AutoDisposeProvider<FavoritesRepository>.internal(
  favoritesRepository,
  name: r'favoritesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoritesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoritesRepositoryRef = AutoDisposeProviderRef<FavoritesRepository>;
String _$favoritesHash() => r'2d4e46c6f6cff78904b49d619c90fbd631fef477';

/// See also [favorites].
@ProviderFor(favorites)
final favoritesProvider =
    AutoDisposeStreamProvider<List<FavoriteModel>>.internal(
  favorites,
  name: r'favoritesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$favoritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoritesRef = AutoDisposeStreamProviderRef<List<FavoriteModel>>;
String _$isFavoriteHash() => r'f403f0e189bc6e57094fb3d2c046d034551cdc12';

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

/// See also [isFavorite].
@ProviderFor(isFavorite)
const isFavoriteProvider = IsFavoriteFamily();

/// See also [isFavorite].
class IsFavoriteFamily extends Family<AsyncValue<bool>> {
  /// See also [isFavorite].
  const IsFavoriteFamily();

  /// See also [isFavorite].
  IsFavoriteProvider call(
    String providerId,
  ) {
    return IsFavoriteProvider(
      providerId,
    );
  }

  @override
  IsFavoriteProvider getProviderOverride(
    covariant IsFavoriteProvider provider,
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
  String? get name => r'isFavoriteProvider';
}

/// See also [isFavorite].
class IsFavoriteProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isFavorite].
  IsFavoriteProvider(
    String providerId,
  ) : this._internal(
          (ref) => isFavorite(
            ref as IsFavoriteRef,
            providerId,
          ),
          from: isFavoriteProvider,
          name: r'isFavoriteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isFavoriteHash,
          dependencies: IsFavoriteFamily._dependencies,
          allTransitiveDependencies:
              IsFavoriteFamily._allTransitiveDependencies,
          providerId: providerId,
        );

  IsFavoriteProvider._internal(
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
  Override overrideWith(
    FutureOr<bool> Function(IsFavoriteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsFavoriteProvider._internal(
        (ref) => create(ref as IsFavoriteRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsFavoriteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavoriteProvider && other.providerId == providerId;
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
mixin IsFavoriteRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `providerId` of this provider.
  String get providerId;
}

class _IsFavoriteProviderElement extends AutoDisposeFutureProviderElement<bool>
    with IsFavoriteRef {
  _IsFavoriteProviderElement(super.provider);

  @override
  String get providerId => (origin as IsFavoriteProvider).providerId;
}

String _$favoriteToggleHash() => r'101eb678eb7c18109b61d8a405856f27d45ab47a';

abstract class _$FavoriteToggle extends BuildlessAutoDisposeNotifier<bool> {
  late final String providerId;

  bool build(
    String providerId,
  );
}

/// See also [FavoriteToggle].
@ProviderFor(FavoriteToggle)
const favoriteToggleProvider = FavoriteToggleFamily();

/// See also [FavoriteToggle].
class FavoriteToggleFamily extends Family<bool> {
  /// See also [FavoriteToggle].
  const FavoriteToggleFamily();

  /// See also [FavoriteToggle].
  FavoriteToggleProvider call(
    String providerId,
  ) {
    return FavoriteToggleProvider(
      providerId,
    );
  }

  @override
  FavoriteToggleProvider getProviderOverride(
    covariant FavoriteToggleProvider provider,
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
  String? get name => r'favoriteToggleProvider';
}

/// See also [FavoriteToggle].
class FavoriteToggleProvider
    extends AutoDisposeNotifierProviderImpl<FavoriteToggle, bool> {
  /// See also [FavoriteToggle].
  FavoriteToggleProvider(
    String providerId,
  ) : this._internal(
          () => FavoriteToggle()..providerId = providerId,
          from: favoriteToggleProvider,
          name: r'favoriteToggleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$favoriteToggleHash,
          dependencies: FavoriteToggleFamily._dependencies,
          allTransitiveDependencies:
              FavoriteToggleFamily._allTransitiveDependencies,
          providerId: providerId,
        );

  FavoriteToggleProvider._internal(
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
  bool runNotifierBuild(
    covariant FavoriteToggle notifier,
  ) {
    return notifier.build(
      providerId,
    );
  }

  @override
  Override overrideWith(FavoriteToggle Function() create) {
    return ProviderOverride(
      origin: this,
      override: FavoriteToggleProvider._internal(
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
  AutoDisposeNotifierProviderElement<FavoriteToggle, bool> createElement() {
    return _FavoriteToggleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteToggleProvider && other.providerId == providerId;
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
mixin FavoriteToggleRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `providerId` of this provider.
  String get providerId;
}

class _FavoriteToggleProviderElement
    extends AutoDisposeNotifierProviderElement<FavoriteToggle, bool>
    with FavoriteToggleRef {
  _FavoriteToggleProviderElement(super.provider);

  @override
  String get providerId => (origin as FavoriteToggleProvider).providerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
