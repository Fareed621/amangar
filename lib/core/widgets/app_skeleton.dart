// lib/core/widgets/app_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Shimmer skeleton widgets used during loading states.
/// Never show a full-screen spinner on content screens — use skeletons.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton._({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.isCircle,
  });

  final double? width;
  final double height;
  final double radius;
  final bool isCircle;

  /// Rectangular skeleton — for text lines, buttons, etc.
  factory AppSkeleton.rect({
    Key? key,
    double? width,
    required double height,
    double? radius,
  }) =>
      AppSkeleton._(
        key: key,
        width: width,
        height: height,
        radius: radius ?? AppRadius.sm,
        isCircle: false,
      );

  /// Circular skeleton — for avatars.
  factory AppSkeleton.circle({
    Key? key,
    required double size,
  }) =>
      AppSkeleton._(
        key: key,
        width: size,
        height: size,
        radius: size / 2,
        isCircle: true,
      );

  /// Card-shaped skeleton — for card containers.
  factory AppSkeleton.card({
    Key? key,
    double? width,
    required double height,
  }) =>
      AppSkeleton._(
        key: key,
        width: width,
        height: height,
        radius: AppRadius.lg,
        isCircle: false,
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.background,
      period: AppDurations.skeleton,
      child: Container(
        width: isCircle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: isCircle
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
