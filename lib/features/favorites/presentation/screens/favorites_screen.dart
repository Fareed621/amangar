import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../hirer_dashboard/presentation/providers/hirer_dashboard_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(hirerDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Your Favorites', style: AppTextStyles.headlineSmall),
      ),
      body: dashboardState.when(
        data: (state) {
          if (state.favorites.isEmpty) {
            return const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on a provider\'s profile to save them here.',
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.85,
            ),
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final favorite = state.favorites[index];
              return _FavoriteGridItem(
                favorite: favorite,
                onTap: () => context.push(RouteNames.providerDetailPath(favorite.providerId)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(hirerDashboardProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _FavoriteGridItem extends StatelessWidget {
  const _FavoriteGridItem({required this.favorite, required this.onTap});

  final FavoriteModel favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32.w,
              backgroundImage: favorite.providerPhoto != null ? NetworkImage(favorite.providerPhoto!) : null,
              child: favorite.providerPhoto == null ? Icon(Icons.person, size: 32.w) : null,
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    favorite.providerName,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (favorite.isVerified) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.verified_rounded, size: 16.w, color: AppColors.primary),
                ],
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              favorite.serviceCategory.toUpperCase(),
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppColors.warning, size: 16.w),
                SizedBox(width: 4.w),
                Text(favorite.rating.toString(), style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
