// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum _AppButtonVariant { primary, secondary, text }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : _variant = _AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final Widget? icon;
  final _AppButtonVariant _variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget child;
    if (widget.isLoading) {
      child = SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget._variant == _AppButtonVariant.primary
              ? AppColors.onPrimary
              : AppColors.primary,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            SizedBox(width: AppSpacing.sm),
          ],
          Text(widget.label),
        ],
      );
    }

    Widget button;
    switch (widget._variant) {
      case _AppButtonVariant.primary:
        button = Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: ElevatedButton(
            onPressed: isDisabled ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(widget.width ?? double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );
      case _AppButtonVariant.secondary:
        button = Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: OutlinedButton(
            onPressed: isDisabled ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(widget.width ?? double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );
      case _AppButtonVariant.text:
        button = Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: TextButton(
            onPressed: isDisabled ? null : widget.onPressed,
            style: TextButton.styleFrom(
              minimumSize: Size(widget.width ?? double.infinity, 52.h),
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && !isDisabled ? 0.97 : 1.0,
        duration: AppDurations.fast,
        child: button,
      ),
    );
  }
}
