import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12.h, width: 100.w, color: Colors.white),
                        SizedBox(height: 4.h),
                        Container(height: 10.h, width: 60.w, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(height: 20.h, width: 60.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.full))),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(height: 14.h, width: 50.w, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
