// lib/core/widgets/provider_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/provider_profile_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_avatar.dart';
import 'rating_stars.dart';

/// Full-width provider card for list views.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.user,
    required this.profile,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  }) : _compact = false;

  const ProviderCard.compact({
    super.key,
    required this.user,
    required this.profile,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  }) : _compact = true;

  final UserModel user;
  final ProviderProfileModel profile;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool _compact;

  @override
  Widget build(BuildContext context) {
    return _compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar + Name/City + Heart
              Row(
                children: [
                  AppAvatar(
                    imageUrl: user.profilePhoto,
                    size: 56.w,
                    name: user.name,
                    showOnlineIndicator: true,
                    isOnline: user.isOnline,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: AppTextStyles.headlineSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.verified_rounded,
                                size: 16.w,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user.city ?? '',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (onFavoriteTap != null)
                    IconButton(
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? AppColors.error : AppColors.textTertiary,
                        size: 22.w,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Row 2: Category badge + Rating + Price
              Row(
                children: [
                  _CategoryBadge(category: profile.serviceCategory),
                  SizedBox(width: AppSpacing.sm),
                  RatingStars(
                    rating: user.rating,
                    showCount: true,
                    reviewCount: user.totalReviews,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatPricePerDay(profile.fullTimeRate),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        Formatters.formatPricePerHour(profile.partTimeRate),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
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
                  child: AppAvatar(
                    imageUrl: user.profilePhoto,
                    size: 48.w,
                    name: user.name,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: AppTextStyles.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      SizedBox(width: 2.w),
                      Icon(Icons.verified_rounded, size: 12.w, color: AppColors.primary),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                _CategoryBadge(category: profile.serviceCategory, small: true),
                SizedBox(height: 4.h),
                RatingStars(rating: user.rating, size: 11.sp),
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatPricePerDay(profile.fullTimeRate),
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

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category, this.small = false});
  final String category;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final isCook = category == 'cook';
    final bg = isCook ? AppColors.cookTint : AppColors.maidTint;
    final fg = isCook ? AppColors.secondary : AppColors.primary;
    final label = isCook ? 'Cook' : 'Maid';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6.w : 8.w,
        vertical: small ? 2.h : 3.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: (small ? AppTextStyles.caption : AppTextStyles.labelSmall)
            .copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
