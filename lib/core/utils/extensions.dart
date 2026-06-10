// lib/core/utils/extensions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// ── String extensions ────────────────────────────────────────────────────────

extension StringExtension on String {
  /// True if matches Pakistani mobile number format 03XXXXXXXXX.
  bool get isValidPhone => RegExp(r'^03[0-9]{9}$').hasMatch(this);

  /// Converts display format "03XX..." to stored format "+923XX...".
  String get toStoredPhone {
    final clean = replaceAll(' ', '');
    if (clean.startsWith('03')) return '+92${clean.substring(1)}';
    return clean;
  }

  /// Converts stored "+923XX..." to display "03XX XXXXXXX".
  String get toDisplayPhone {
    String s = this;
    if (s.startsWith('+92')) s = '0${s.substring(3)}';
    if (s.length >= 5) return '${s.substring(0, 4)} ${s.substring(4)}';
    return s;
  }

  /// Capitalises only the first letter.
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates to [max] characters and appends "…" if longer.
  String truncate(int max) {
    if (length <= max) return this;
    return '${substring(0, max)}…';
  }
}

// ── DateTime extensions ──────────────────────────────────────────────────────

extension DateTimeExtension on DateTime {
  /// Returns 'YYYY-MM-DD' key used in availability dateOverrides path.
  String get toDateKey =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// True if this and [other] share the same year, month, and day.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

// ── Timestamp extensions ─────────────────────────────────────────────────────

extension TimestampExtension on Timestamp {
  /// Converts to a local DateTime.
  DateTime get toLocal => toDate().toLocal();
}

// ── BuildContext extensions ──────────────────────────────────────────────────

extension ContextExtension on BuildContext {
  /// Short-hand for AppLocalizations.of(context)!
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// True if the current text direction is RTL (Urdu locale).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
