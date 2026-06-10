// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// A labelled text field with real-time validation (tracks "touched" state).
/// Label is shown above the field (not as a floating label).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final void Function(String)? onChanged;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _touched = false;
  String? _error;

  void _handleChange(String value) {
    if (!_touched) setState(() => _touched = true);
    final err = widget.validator?.call(value);
    if (_error != err) setState(() => _error = err);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final showCount = widget.maxLength != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelMedium),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: _handleChange,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          buildCounter: showCount
              ? (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  Text(
                    '$currentLength/${widget.maxLength}',
                    style: AppTextStyles.caption,
                  )
              : null,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: _touched ? _error : null,
            errorStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
