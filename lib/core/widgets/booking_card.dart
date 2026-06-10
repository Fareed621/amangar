// lib/core/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_avatar.dart';
import 'status_badge.dart';

/// Booking card used in hirer and provider booking lists.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.userRole,
    this.onTap,
    this.onBookAgain,
  });

  final BookingModel booking;
  final String userRole; // 'hirer' | 'provider'
  final VoidCallback? onTap;
  final VoidCallback? onBookAgain;

  @override
  Widget build(BuildContext context) {
    // Show the OTHER party's info
    final isHirer = userRole == 'hirer';
    final otherName = isHirer ? booking.providerName : booking.hirerName;
    final otherPhoto = isHirer ? booking.providerPhoto : booking.hirerPhoto;

    final showBookAgain = onBookAgain != null &&
        (booking.status == 'completed' || booking.status == 'cancelled');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Row 1: Avatar + Name/Date + Status badge
              Row(
                children: [
                  AppAvatar(
                    imageUrl: otherPhoto,
                    size: 40.w,
                    name: otherName,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherName,
                          style: AppTextStyles.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          booking.dates.isNotEmpty
                              ? Formatters.formatDate(booking.dates.first)
                              : '',
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(
                          _serviceTypeLabel(booking.serviceType),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: booking.status),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Row 2: Price + Book Again
              Row(
                children: [
                  Text(
                    Formatters.formatPrice(booking.displayPrice),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (showBookAgain)
                    TextButton(
                      onPressed: onBookAgain,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Book Again',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _serviceTypeLabel(String type) {
    switch (type) {
      case 'full_time':
        return 'Full-time';
      case 'part_time':
        return 'Part-time';
      default:
        return type;
    }
  }
}
