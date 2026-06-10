// lib/core/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Manages the app locale (English / Urdu).
/// SharedPreferences persistence will be added in Phase 6.
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _supportedLocales = [Locale('en'), Locale('ur')];

  @override
  Locale build() {
    // Default to English; Phase 6 will read from SharedPreferences.
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    assert(_supportedLocales.contains(locale), 'Unsupported locale: $locale');
    state = locale;
    // TODO Phase 6: persist to SharedPreferences
  }

  void toggleLocale() {
    state = state.languageCode == 'en'
        ? const Locale('ur')
        : const Locale('en');
  }
}
