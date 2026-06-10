// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsRepositoryHash() =>
    r'dd97ffce4e9c2fc872d0b7b6a57c243ba28eb7f6';

/// See also [notificationsRepository].
@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider =
    AutoDisposeProvider<NotificationsRepository>.internal(
  notificationsRepository,
  name: r'notificationsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsRepositoryRef
    = AutoDisposeProviderRef<NotificationsRepository>;
String _$notificationsHash() => r'32430821dc246ddb2df22e798dbed35b4af3f2c4';

/// See also [notifications].
@ProviderFor(notifications)
final notificationsProvider =
    AutoDisposeStreamProvider<List<NotificationModel>>.internal(
  notifications,
  name: r'notificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsRef
    = AutoDisposeStreamProviderRef<List<NotificationModel>>;
String _$notificationUnreadCountHash() =>
    r'68bb102cf1880d904dcf75a46655629606e363a3';

/// See also [notificationUnreadCount].
@ProviderFor(notificationUnreadCount)
final notificationUnreadCountProvider = AutoDisposeStreamProvider<int>.internal(
  notificationUnreadCount,
  name: r'notificationUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationUnreadCountRef = AutoDisposeStreamProviderRef<int>;
String _$markNotificationReadHash() =>
    r'3b3e3898dae81f8aab55a588da6d71cd1bb1e121';

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

/// See also [markNotificationRead].
@ProviderFor(markNotificationRead)
const markNotificationReadProvider = MarkNotificationReadFamily();

/// See also [markNotificationRead].
class MarkNotificationReadFamily extends Family<AsyncValue<void>> {
  /// See also [markNotificationRead].
  const MarkNotificationReadFamily();

  /// See also [markNotificationRead].
  MarkNotificationReadProvider call(
    String id,
  ) {
    return MarkNotificationReadProvider(
      id,
    );
  }

  @override
  MarkNotificationReadProvider getProviderOverride(
    covariant MarkNotificationReadProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'markNotificationReadProvider';
}

/// See also [markNotificationRead].
class MarkNotificationReadProvider extends AutoDisposeFutureProvider<void> {
  /// See also [markNotificationRead].
  MarkNotificationReadProvider(
    String id,
  ) : this._internal(
          (ref) => markNotificationRead(
            ref as MarkNotificationReadRef,
            id,
          ),
          from: markNotificationReadProvider,
          name: r'markNotificationReadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markNotificationReadHash,
          dependencies: MarkNotificationReadFamily._dependencies,
          allTransitiveDependencies:
              MarkNotificationReadFamily._allTransitiveDependencies,
          id: id,
        );

  MarkNotificationReadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<void> Function(MarkNotificationReadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkNotificationReadProvider._internal(
        (ref) => create(ref as MarkNotificationReadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _MarkNotificationReadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkNotificationReadProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarkNotificationReadRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MarkNotificationReadProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with MarkNotificationReadRef {
  _MarkNotificationReadProviderElement(super.provider);

  @override
  String get id => (origin as MarkNotificationReadProvider).id;
}

String _$totalUnreadCountHash() => r'd8ad5e387616ab2572b1889d235a996b29e42ad3';

/// See also [totalUnreadCount].
@ProviderFor(totalUnreadCount)
final totalUnreadCountProvider = AutoDisposeStreamProvider<int>.internal(
  totalUnreadCount,
  name: r'totalUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
