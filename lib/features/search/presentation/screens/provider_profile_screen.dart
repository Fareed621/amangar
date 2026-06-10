import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/models/rating_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../chat/presentation/providers/chat_list_provider.dart';
import '../providers/search_provider.dart';

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key, required this.providerId});

  final String providerId;

  Future<void> _openChat(BuildContext context, WidgetRef ref, String name, String? photo) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    try {
      final chatId = await ref.read(chatActionsProvider).createOrGetChat(
        otherUid: providerId,
        currentName: currentUser.name,
        otherName: name,
        currentPhoto: currentUser.profilePhoto,
        otherPhoto: photo,
      );

      if (context.mounted) {
        context.push(
          RouteNames.chatDetailPath(chatId),
          extra: {
            'otherName': name,
            'otherUid': providerId,
            'otherPhoto': photo,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(providerDetailProvider(providerId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isViewerHirer = currentUser?.role == 'hirer';
    final isViewerSelf = currentUser?.uid == providerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: (isViewerHirer && !isViewerSelf)
          ? Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Book Now',
                      onPressed: () => context.push(RouteNames.bookingFlowPath(providerId)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: AppButton.secondary(
                      label: 'Chat',
                      onPressed: () {
                        detailState.whenData((p) {
                          if (p != null) {
                            _openChat(context, ref, p.user.name, p.user.profilePhoto);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          : (isViewerSelf ? Container(
              height: 80.h,
              alignment: Alignment.center,
              color: AppColors.surface,
              child: Text('This is how your profile looks to others', style: AppTextStyles.bodyMedium),
            ) : null),
      body: detailState.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: AppErrorWidget(
                message: 'Provider Not Found',
                // subtitle removed
                onRetry: () => context.pop(),
              ),
            );
          }
          return _ProviderProfileContent(data: data, isViewerHirer: isViewerHirer);
        },
        loading: () => const _ProviderProfileSkeleton(),
        error: (e, st) => Center(
          child: AppErrorWidget(
            message: 'Error Loading Profile',
            // subtitle removed
            onRetry: () => ref.invalidate(providerDetailProvider(providerId)),
          ),
        ),
      ),
    );
  }
}

class _ProviderProfileContent extends ConsumerWidget {
  const _ProviderProfileContent({required this.data, required this.isViewerHirer});

  final ProviderWithProfileModel data;
  final bool isViewerHirer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = data.profile!;
    final user = data.user;
    final isFav = ref.watch(isFavoriteProvider(user.uid)).valueOrNull ?? false;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240.h,
          pinned: true,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              user.name,
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: user.profilePhoto!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                // Gradient overlay for text readability
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
            if (isViewerHirer)
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ).animate(target: isFav ? 1 : 0).scaleXY(begin: 1, end: 1.2, duration: 200.ms, curve: Curves.elasticOut),
                onPressed: () {
                  ref.read(favoriteToggleProvider(user.uid).notifier).toggle(
                        provider: user,
                        profile: profile,
                        currentlyFavorited: isFav,
                      );
                },
              ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => showReportBottomSheet(context, user),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            // Section 1: Header Info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          user.serviceCategory?.toUpperCase() ?? 'SERVICE',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.location_on_outlined, size: 16.w, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Text(user.city ?? 'Unknown City', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      RatingStars(rating: user.rating, size: 20.w),
                      SizedBox(width: 8.w),
                      Text('(${user.totalReviews} reviews)', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Section 2: About
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'About'),
                  SizedBox(height: 12.h),
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    Text(profile.bio!, style: AppTextStyles.bodyMedium),
                    SizedBox(height: 16.h),
                  ],
                  if (profile.skills.isNotEmpty) ...[
                    Text('Skills', style: AppTextStyles.labelLarge),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: profile.skills.map((s) => Chip(label: Text(s))).toList(),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  if (profile.languages.isNotEmpty) ...[
                    Text('Languages', style: AppTextStyles.labelLarge),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: profile.languages.map((l) => Chip(label: Text(l))).toList(),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  Text('Experience', style: AppTextStyles.labelLarge),
                  SizedBox(height: 4.h),
                  Text(profile.experienceLevel.toUpperCase(), style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Divider(),

            // Section 3: Services & Pricing
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Services & Pricing'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            children: [
                              Text('Full-time', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              SizedBox(height: 4.h),
                              Text(Formatters.formatPricePerDay(profile.fullTimeRate), style: AppTextStyles.headlineSmall),
                              Text('per month', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            children: [
                              Text('Part-time', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              SizedBox(height: 4.h),
                              Text(Formatters.formatPricePerHour(profile.partTimeRate), style: AppTextStyles.headlineSmall),
                              Text('per hour', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Section 4: Portfolio
            if (profile.portfolioPhotos.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Portfolio'),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 100.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.portfolioPhotos.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: InteractiveViewer(
                                  child: CachedNetworkImage(
                                    imageUrl: profile.portfolioPhotos[i],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: CachedNetworkImage(
                              imageUrl: profile.portfolioPhotos[i],
                              width: 80.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Section 5: Reviews
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(title: 'Reviews'),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (user.totalReviews == 0)
                    Text('No reviews yet. Be the first!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                  else
                    Consumer(
                      builder: (context, ref, _) {
                        final ratingsAsync = ref.watch(providerRatingsProvider(user.uid));
                        return ratingsAsync.when(
                          data: (ratings) => Column(
                            children: [
                              ...ratings.take(3).map((r) => _RatingCard(rating: r)),
                              if (ratings.length > 3)
                                AppButton.text(
                                  label: 'Load More',
                                  onPressed: () => ref.read(providerRatingsProvider(user.uid).notifier).loadMore(),
                                  width: double.infinity,
                                ),
                            ],
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Failed to load reviews', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                        );
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 100.h), // Bottom padding to avoid sticky bar overlap
          ]),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.headlineMedium);
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating});
  final RatingModel rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(rating.fromUserName.substring(0, 1).toUpperCase(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rating.fromUserName, style: AppTextStyles.labelLarge),
                    Row(
                      children: [
                        RatingStars(rating: rating.rating.toDouble(), size: 14.w),
                        SizedBox(width: 8.w),
                        Text(Formatters.formatDate(rating.createdAt), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(rating.comment!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ProviderProfileSkeleton extends StatelessWidget {
  const _ProviderProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240.h,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: AppColors.divider,
              highlightColor: AppColors.surface,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.divider,
                    highlightColor: AppColors.surface,
                    child: Container(height: 24.h, width: 200.w, color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Shimmer.fromColors(
                    baseColor: AppColors.divider,
                    highlightColor: AppColors.surface,
                    child: Container(height: 16.h, width: 100.w, color: Colors.white),
                  ),
                  SizedBox(height: 32.h),
                  Shimmer.fromColors(
                    baseColor: AppColors.divider,
                    highlightColor: AppColors.surface,
                    child: Container(height: 150.h, width: double.infinity, color: Colors.white),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
