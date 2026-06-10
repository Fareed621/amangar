import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/provider_card.dart';
import '../../data/models/search_filter_model.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class ProviderListScreen extends ConsumerStatefulWidget {
  const ProviderListScreen({super.key, this.category});

  final String? category;

  @override
  ConsumerState<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends ConsumerState<ProviderListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: AppLimits.searchDebounceMs), () {
      ref.read(searchFilterProvider.notifier).setQuery(query);
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  int _getActiveFilterCount(SearchFilterModel filter) {
    int count = 0;
    if (filter.city != null && filter.city!.isNotEmpty) count++;
    if (filter.serviceCategory != null && filter.serviceCategory!.isNotEmpty) count++;
    if (filter.minRating > 0) count++;
    if (filter.experienceLevels.isNotEmpty) count++;
    if (filter.availabilityType != 'both') count++;
    if (filter.verifiedOnly) count++;
    if (filter.minPrice != null || filter.maxPrice != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final resultsState = ref.watch(searchResultsProvider);
    final activeFilters = _getActiveFilterCount(filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for cooks, maids...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20.w),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showFilters,
                color: AppColors.onBackground,
              ),
              if (activeFilters > 0)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text(
                      activeFilters.toString(),
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
        bottom: activeFilters > 0 ? PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: SizedBox(
            height: 48.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                if (filter.serviceCategory != null)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Chip(
                      label: Text(filter.serviceCategory!),
                      onDeleted: () => ref.read(searchFilterProvider.notifier).setServiceCategory(null),
                    ),
                  ),
                if (filter.city != null)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Chip(
                      label: Text(filter.city!),
                      onDeleted: () => ref.read(searchFilterProvider.notifier).setCity(null),
                    ),
                  ),
              ],
            ),
          ),
        ) : null,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
            ref.read(searchResultsProvider.notifier).loadMore();
          }
          return false;
        },
        child: resultsState.when(
          data: (providers) {
            if (providers.isEmpty) {
              return AppEmptyState(
                title: 'No providers found',
                subtitle: 'Try adjusting your filters',
                actionLabel: 'Clear Filters',
                onAction: () {
                  _searchCtrl.clear();
                  ref.read(searchFilterProvider.notifier).clearAll();
                },
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: providers.length + (ref.watch(searchResultsProvider).isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == providers.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final p = providers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ProviderCard(
                    user: p.user,
                    profile: p.profile!,
                    onTap: () => context.push(RouteNames.providerDetailPath(p.user.uid)),
                  ).animate(delay: Duration(milliseconds: index * 60)).fadeIn().slideY(),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => AppErrorWidget(
            message: 'An error occurred',
            // subtitle removed
            onRetry: () => ref.invalidate(searchResultsProvider),
          ),
        ),
      ),
    );
  }
}
