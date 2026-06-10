// lib/core/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../utils/extensions.dart';

/// Pill-shaped status badge with icon and label.
/// Colors and icons are determined by the [status] string.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status, context);
    return Container(
      height: 28.h,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: config.background.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: config.background.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12.w, color: config.background),
          SizedBox(width: 4.w),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.background,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _configFor(String status, BuildContext context) {
    switch (status) {
      case 'pending':
        return _BadgeConfig(
          background: AppColors.statusPending,
          label: context.l10n.statusPending,
          icon: Icons.schedule_rounded,
        );
      case 'confirmed':
        return _BadgeConfig(
          background: AppColors.statusConfirmed,
          label: context.l10n.statusConfirmed,
          icon: Icons.check_circle_outline_rounded,
        );
      case 'in_progress':
        return _BadgeConfig(
          background: AppColors.statusInProgress,
          label: context.l10n.statusInProgress,
          icon: Icons.play_circle_outline_rounded,
        );
      case 'completed':
        return _BadgeConfig(
          background: AppColors.statusCompleted,
          label: context.l10n.statusCompleted,
          icon: Icons.task_alt_rounded,
        );
      case 'cancelled':
        return _BadgeConfig(
          background: AppColors.statusCancelled,
          label: context.l10n.statusCancelled,
          icon: Icons.cancel_outlined,
        );
      case 'rejected':
        return _BadgeConfig(
          background: AppColors.statusRejected,
          label: context.l10n.statusRejected,
          icon: Icons.block_rounded,
        );
      default:
        return _BadgeConfig(
          background: AppColors.textTertiary,
          label: status,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.background,
    required this.label,
    required this.icon,
  });
  final Color background;
  final String label;
  final IconData icon;
}
