// lib/features/hirer_dashboard/presentation/widgets/prayer_times_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/prayer_times_provider.dart';
import '../../../../core/services/prayer_times_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays today's five prayer times in a horizontally scrollable row.
///
/// Drop this widget into any [Column] or [SliverList]; it is self-contained
/// and handles its own loading/error states using [ref.watch].
///
/// Example:
/// ```dart
/// const PrayerTimesCard(),
/// ```
class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(prayerTimesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Prayer Times', style: AppTextStyles.headlineMedium),
            Text(
              'Karachi, PKT',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        prayerAsync.when(
          data: (model) => _PrayerTimesRow(model: model),
          loading: () => const _PrayerTimesRowSkeleton(),
          error: (e, _) => _PrayerTimesError(
            onRetry: () => ref.invalidate(prayerTimesProvider),
          ),
        ),
      ],
    );
  }
}

// ── Data row ─────────────────────────────────────────────────────────────────

class _PrayerTimesRow extends StatelessWidget {
  const _PrayerTimesRow({required this.model});
  final PrayerTimesModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: model.entries.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (ctx, i) {
          final entry = model.entries[i];
          return _PrayerTile(
            emoji: entry.emoji,
            name: entry.name,
            time: entry.time,
          )
              .animate(delay: Duration(milliseconds: i * 60))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
        },
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.emoji,
    required this.name,
    required this.time,
  });

  final String emoji;
  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 4.h),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            child: Text(
              time,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────

class _PrayerTimesRowSkeleton extends StatelessWidget {
  const _PrayerTimesRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, __) => Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _PrayerTimesError extends StatelessWidget {
  const _PrayerTimesError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.textTertiary, size: 18.w),
          SizedBox(width: 8.w),
          Text(
            'Could not load prayer times.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Retry',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
