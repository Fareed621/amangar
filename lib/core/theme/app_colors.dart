// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// All colour constants for the AmanGhar design system.
/// Matches flutter-architecture.md Section 7.1 exactly.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF00695C); // Deep Teal
  static const primaryLight = Color(0xFF4DB6AC); // Light Teal
  static const primaryDark  = Color(0xFF004D40); // Darker Teal
  static const onPrimary    = Color(0xFFFFFFFF);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const secondary      = Color(0xFFFF8F00); // Warm Orange
  static const secondaryLight = Color(0xFFFFB300);
  static const onSecondary    = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const success      = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const error        = Color(0xFFF44336);
  static const errorLight   = Color(0xFFFFEBEE);
  static const warning      = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);
  static const info         = Color(0xFF2196F3);
  static const infoLight    = Color(0xFFE3F2FD);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const background     = Color(0xFFFFFFFF);
  static const surface        = Color(0xFFF5F5F5);
  static const surfaceVariant = Color(0xFFEEEEEE);
  static const divider        = Color(0xFFE0E0E0);
  static const onBackground   = Color(0xFF212121);
  static const onSurface      = Color(0xFF424242);
  static const textSecondary  = Color(0xFF757575);
  static const textTertiary   = Color(0xFF9E9E9E);
  static const textDisabled   = Color(0xFFBDBDBD);

  // ── Category tints ───────────────────────────────────────────────────────
  static const cookTint = Color(0xFFFFF3E0); // Light orange
  static const maidTint = Color(0xFFE0F2F1); // Light teal

  // ── Status badge colors ──────────────────────────────────────────────────
  static const statusPending    = Color(0xFFFF9800);
  static const statusConfirmed  = Color(0xFF2196F3);
  static const statusInProgress = Color(0xFF9C27B0);
  static const statusCompleted  = Color(0xFF4CAF50);
  static const statusCancelled  = Color(0xFF9E9E9E);
  static const statusRejected   = Color(0xFFF44336);

  // ── Chat ─────────────────────────────────────────────────────────────────
  static const senderBubble   = Color(0xFF00695C); // Primary teal
  static const receiverBubble = Color(0xFFF5F5F5);
  static const senderText     = Color(0xFFFFFFFF);
  static const receiverText   = Color(0xFF212121);
}
