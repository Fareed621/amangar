// lib/core/widgets/rating_stars.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// Read-only star display, optionally showing review count.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size,
    this.showCount = false,
    this.reviewCount,
  });

  final double rating;
  final double? size;
  final bool showCount;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final starSize = size ?? 14.sp;
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: starSize,
            color: AppColors.secondary,
          ),
        if (showCount && reviewCount != null) ...[
          SizedBox(width: AppSpacing.xs),
          Text(
            '($reviewCount)',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Interactive 5-star integer input widget.
class RatingStarsInteractive extends StatefulWidget {
  const RatingStarsInteractive({
    super.key,
    this.initialValue = 0,
    required this.onChanged,
  });

  final int initialValue;
  final void Function(int) onChanged;

  @override
  State<RatingStarsInteractive> createState() => _RatingStarsInteractiveState();
}

class _RatingStarsInteractiveState extends State<RatingStarsInteractive> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () {
            setState(() => _value = star);
            widget.onChanged(star);
          },
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.xs),
            child: Icon(
              star <= _value ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 32.w,
              color: AppColors.secondary,
            ),
          ),
        );
      }),
    );
  }
}
