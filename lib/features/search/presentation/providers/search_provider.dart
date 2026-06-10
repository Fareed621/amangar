import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/models/rating_model.dart';
import '../../data/models/search_filter_model.dart';
import '../../data/search_repository_impl.dart';
import '../../domain/search_repository.dart';

part 'search_provider.g.dart';

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl();
}

@Riverpod(keepAlive: true)
class SearchFilter extends _$SearchFilter {
  @override
  SearchFilterModel build() => const SearchFilterModel();

  void updateFilter(SearchFilterModel filter) => state = filter;
  void clearAll() => state = const SearchFilterModel();
  
  void setQuery(String q) => state = state.copyWith(query: q);
  void setCity(String? city) => state = state.copyWith(city: city);
  void setServiceCategory(String? category) => state = state.copyWith(serviceCategory: category);
  void setMinRating(double minRating) => state = state.copyWith(minRating: minRating);
  void setExperienceLevels(List<String> levels) => state = state.copyWith(experienceLevels: levels);
  void setAvailabilityType(String type) => state = state.copyWith(availabilityType: type);
  void setVerifiedOnly(bool verified) => state = state.copyWith(verifiedOnly: verified);
  void setMinPrice(int? min) => state = state.copyWith(minPrice: min);
  void setMaxPrice(int? max) => state = state.copyWith(maxPrice: max);
  void setSortBy(String sort) => state = state.copyWith(sortBy: sort);
}

@Riverpod(keepAlive: true)
class SearchResults extends _$SearchResults {
  final List<ProviderWithProfileModel> _all = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  Future<List<ProviderWithProfileModel>> build() async {
    final filter = ref.watch(searchFilterProvider);
    _all.clear();
    _lastDoc = null;
    _hasMore = true;
    return _fetchPage(filter);
  }

  Future<List<ProviderWithProfileModel>> _fetchPage(SearchFilterModel filter) async {
    if (!_hasMore) return _all;
    
    final repo = ref.read(searchRepositoryProvider);

    final page = await repo.searchProviders(
      query: filter.query.length >= 2 ? filter.query : null,
      city: filter.city,
      serviceCategory: filter.serviceCategory,
      minRating: filter.minRating,
      experienceLevels: filter.experienceLevels,
      availabilityType: filter.availabilityType,
      verifiedOnly: filter.verifiedOnly,
      minPrice: filter.minPrice,
      maxPrice: filter.maxPrice,
      sortBy: filter.sortBy,
      startAfter: _lastDoc,
      limit: AppLimits.listPaginationLimit * 2,
    );

    if (page.isNotEmpty) {
      final lastUid = page.last.user.uid;
      _lastDoc = await FirebaseFirestore.instance.collection('users').doc(lastUid).get();
    }
    
    _all.addAll(page);
    _hasMore = page.length == AppLimits.listPaginationLimit * 2;
    
    return List.from(_all);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    state = await AsyncValue.guard(() => _fetchPage(ref.read(searchFilterProvider)));
  }
}

@riverpod
Future<ProviderWithProfileModel?> providerDetail(ProviderDetailRef ref, String uid) {
  return ref.read(searchRepositoryProvider).getProviderWithProfile(uid);
}

@riverpod
class ProviderRatings extends _$ProviderRatings {
  final List<RatingModel> _all = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  Future<List<RatingModel>> build(String providerId) async {
    _all.clear();
    _lastDoc = null;
    _hasMore = true;
    return _fetchPage();
  }

  Future<List<RatingModel>> _fetchPage() async {
    if (!_hasMore) return _all;
    
    // We need the raw snapshot to update _lastDoc. 
    // This is handled by passing startAfter to the repo, but the repo returns models.
    // Instead of refactoring the repo interface, we do it properly:
    // Wait, getProviderRatings doesn't return the DocumentSnapshot.
    // I will query here to get the snapshot for pagination:
    Query query = FirebaseFirestore.instance.collection('ratings')
        .where('toUserId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .limit(AppLimits.listPaginationLimit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      _lastDoc = snap.docs.last;
      final newRatings = snap.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      _all.addAll(newRatings);
      _hasMore = snap.docs.length == AppLimits.listPaginationLimit;
    } else {
      _hasMore = false;
    }

    return List.from(_all);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    state = await AsyncValue.guard(() => _fetchPage());
  }
}
