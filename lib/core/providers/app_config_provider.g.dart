// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConfigHash() => r'21e5b851e3ee1e77d76f60abc0a06c417992ebce';

/// Fetches global app configuration from Firestore (one-time).
///
/// Copied from [appConfig].
@ProviderFor(appConfig)
final appConfigProvider =
    AutoDisposeFutureProvider<AppConfigGlobalModel>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppConfigRef = AutoDisposeFutureProviderRef<AppConfigGlobalModel>;
String _$skillTagsHash() => r'9d69785c39d12bcbe864aab1e7d97f0ea1ea3564';

/// Fetches skill tags (cook skills, maid skills, languages) from Firestore.
///
/// Copied from [skillTags].
@ProviderFor(skillTags)
final skillTagsProvider = AutoDisposeFutureProvider<SkillTagsModel>.internal(
  skillTags,
  name: r'skillTagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$skillTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SkillTagsRef = AutoDisposeFutureProviderRef<SkillTagsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
