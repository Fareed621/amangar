import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/provider_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/hirer_dashboard_provider.dart';
import '../../../../core/widgets/app_banner_ad.dart';
import '../widgets/prayer_times_card.dart';

class HirerDashboardScreen extends ConsumerWidget {
  const HirerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(hirerDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(hirerDashboardProvider.notifier).refresh();
        },
        child: dashboardState.when(
          data: (data) => _HirerDashboardContent(state: data),
          loading: () => const _HirerDashboardSkeleton(),
          error: (e, st) => Center(
            child: AppErrorWidget(
              message: context.l10n.errorGeneric,
              // subtitle removed
              onRetry: () => ref.read(hirerDashboardProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }
}

class _HirerDashboardContent extends ConsumerWidget {
  const _HirerDashboardContent({required this.state});

  final HirerDashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = user?.name.split(' ').first ?? 'User';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          toolbarHeight: 64.h,
          title: GestureDetector(
            onTap: () {
              ref.read(searchFilterProvider.notifier).clearAll();
              context.push(RouteNames.providerList);
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(Icons.search, color: AppColors.textTertiary, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Search for cooks, maids...',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            const NotificationBell(),
            SizedBox(width: 8.w),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 20.h),
              Text(
                '${Formatters.timeGreeting()}, $firstName!',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.onBackground),
              ).animate().fadeIn(duration: AppDurations.normal),
              SizedBox(height: 24.h),

              // Category Cards
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(searchFilterProvider.notifier).clearAll();
                        ref.read(searchFilterProvider.notifier).setServiceCategory('cook');
                        context.push(RouteNames.providerList);
                      },
                      child: Container(
                        constraints: BoxConstraints(minHeight: 90.h),
                        decoration: BoxDecoration(
                          color: AppColors.cookTint,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant, color: AppColors.secondary, size: 28.w),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Cooks', style: AppTextStyles.headlineSmall),
                                  Text('Find a cook', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(searchFilterProvider.notifier).clearAll();
                        ref.read(searchFilterProvider.notifier).setServiceCategory('maid');
                        context.push(RouteNames.providerList);
                      },
                      child: Container(
                        constraints: BoxConstraints(minHeight: 90.h),
                        decoration: BoxDecoration(
                          color: AppColors.maidTint,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          children: [
                            Icon(Icons.cleaning_services, color: AppColors.primary, size: 28.w),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Maids', style: AppTextStyles.headlineSmall),
                                  Text('Find a maid', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.15, end: 0, duration: AppDurations.normal, curve: AppCurves.enter),
              SizedBox(height: 28.h),

              // ── Prayer Times ── REST API integration ─────────────────────
              const PrayerTimesCard()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: AppDurations.normal),
              SizedBox(height: 28.h),

              if (state.recentBookings.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Recent Bookings',
                  actionLabel: 'View All',
                  onAction: () => context.push(RouteNames.hirerBookings),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 150.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.recentBookings.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (ctx, i) {
                      final b = state.recentBookings[i];
                      return _RecentBookingCard(booking: b)
                          .animate(delay: Duration(milliseconds: i * 60))
                          .fadeIn()
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
                SizedBox(height: 32.h),
              ],

              if (state.favorites.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Your Favorites',
                  actionLabel: 'View All',
                  onAction: () => context.push(RouteNames.hirerFavorites),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 160.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.favorites.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (ctx, i) {
                      final favorite = state.favorites[i];
                      return _FavoriteCard(
                        favorite: favorite,
                        onTap: () => context.push(RouteNames.providerDetailPath(favorite.providerId)),
                      ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
                SizedBox(height: 32.h),
              ],
              
              const AppBannerAd(),
              SizedBox(height: 16.h),
              _SectionHeader(title: 'Recommended for You'),
              SizedBox(height: 12.h),
              ...List.generate(state.recommendedProviders.length, (i) {
                final p = state.recommendedProviders[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ProviderCard(
                    user: p.user,
                    profile: p.profile!,
                    onTap: () => context.push(RouteNames.providerDetailPath(p.user.uid)),
                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1, end: 0),
                );
              }),
              SizedBox(height: 32.h),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _RecentBookingCard extends StatelessWidget {
  const _RecentBookingCard({required this.booking});

  final BookingModel booking;

  @override
  
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(booking.providerName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.formatDate(booking.dates.first),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          
          SizedBox(height: 8.h),
          AppButton.text(
            label: 'Book Again',
            onPressed: () => context.push('/booking/${booking.providerId}'),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.favorite, this.onTap});
  final FavoriteModel favorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160.w,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 24.w,
                    backgroundImage: favorite.providerPhoto != null ? NetworkImage(favorite.providerPhoto!) : null,
                    child: favorite.providerPhoto == null ? const Icon(Icons.person) : null,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        favorite.providerName,
                        style: AppTextStyles.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (favorite.isVerified) ...[
                      SizedBox(width: 2.w),
                      Icon(Icons.verified_rounded, size: 12.w, color: AppColors.primary),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(favorite.serviceCategory.toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                SizedBox(height: 4.h),
                Row(children: [
                  Icon(Icons.star, color: AppColors.warning, size: 11.sp),
                  Text(favorite.rating.toString(), style: AppTextStyles.caption),
                ]),
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatPricePerDay(favorite.fullTimeRate),
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HirerDashboardSkeleton extends StatelessWidget {
  const _HirerDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          toolbarHeight: 64.h,
          title: Shimmer.fromColors(
            baseColor: AppColors.divider,
            highlightColor: AppColors.surface,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 20.h),
              Shimmer.fromColors(
                baseColor: AppColors.divider,
                highlightColor: AppColors.surface,
                child: Container(
                  height: 20.h,
                  width: 180.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: AppColors.divider,
                      highlightColor: AppColors.surface,
                      child: Container(
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: AppColors.divider,
                      highlightColor: AppColors.surface,
                      child: Container(
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Shimmer.fromColors(
                baseColor: AppColors.divider,
                highlightColor: AppColors.surface,
                child: Container(
                  height: 24.h,
                  width: 140.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 120.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: AppColors.divider,
                    highlightColor: AppColors.surface,
                    child: Container(
                      width: 200.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Shimmer.fromColors(
                baseColor: AppColors.divider,
                highlightColor: AppColors.surface,
                child: Container(
                  height: 24.h,
                  width: 180.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              ...List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Shimmer.fromColors(
                  baseColor: AppColors.divider,
                  highlightColor: AppColors.surface,
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                ),
              )),
            ]),
          ),
        ),
      ],
    );
  }
}