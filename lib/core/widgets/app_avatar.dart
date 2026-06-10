// lib/core/widgets/app_avatar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Circular avatar showing CachedNetworkImage if [imageUrl] is provided,
/// otherwise shows initials. Optionally shows a green online indicator dot.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.size,
    required this.name,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  final String? imageUrl;
  final double size;
  final String name;
  final bool showOnlineIndicator;
  final bool isOnline;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _avatarColor() {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF5722),
    ];
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar = ClipOval(
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildInitials(),
              errorWidget: (_, __, ___) => _buildInitials(),
            )
          : _buildInitials(),
    );

    if (!showOnlineIndicator) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.textDisabled,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials() => Container(
        width: size,
        height: size,
        color: _avatarColor(),
        child: Center(
          child: Text(
            _initials(),
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: size * 0.35,
            ),
          ),
        ),
      );
}
