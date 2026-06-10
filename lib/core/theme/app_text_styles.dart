// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// All text style constants for the AmanGhar design system.
/// All sizes use .sp from ScreenUtil — never hardcode pt/px.
/// Styles are static getters (not const) because ScreenUtil must be
/// initialised before calling .sp.
class AppTextStyles {
  AppTextStyles._();

  // ── Display / Headline (Poppins) ─────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  // ── Body (Inter) ─────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Label (Inter medium) ─────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ── Caption ──────────────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}
