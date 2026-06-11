// lib/core/services/prayer_times_service.dart
import 'dart:convert';
import 'dart:developer'; // Timeline API for DevTools Flame Graph profiling
import 'package:flutter/foundation.dart'; // compute() — background Isolate helper
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// ── LAYER 1: Top-level parse function (REQUIRED for compute()) ────────────────
//
// Dart's compute() helper serialises this function pointer + the raw String
// argument and runs them in a separate Dart Isolate on a background OS thread.
//
// RULES:
//  • Must be top-level (not a closure, not a class method) — Isolate constraint.
//  • Argument and return type must be JSON-serialisable primitives or typed
//    objects — PrayerTimesModel qualifies because we construct it inside here.
//
// LAYER 2: Timeline profiling block wraps the actual CPU work (jsonDecode +
// model construction) so that a named block appears in DevTools → Flame Graph
// directly on the background isolate's thread lane.
PrayerTimesModel _parsePrayerTimesResponse(String rawBody) {
  // Profile marker: visible in the background-isolate lane of DevTools.
  Timeline.startSync('PrayerTimes_JSONParse');
  try {
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final code = body['code'] as int?;
    if (code != 200) {
      throw PrayerTimesException(
        'API returned code $code: ${body['status']}',
      );
    }

    final data = body['data'] as Map<String, dynamic>?;
    final timings = data?['timings'] as Map<String, dynamic>?;
    final date = data?['date'] as Map<String, dynamic>?;
    final readable = date?['readable'] as String?;

    if (timings == null) {
      throw const PrayerTimesException('Missing timings in API response');
    }

    // Strip timezone suffix from times like "05:12 (PKT)"
    String clean(String? raw) => (raw ?? '--:--').split(' ').first.trim();

    return PrayerTimesModel(
      city: 'Karachi',
      date: readable ?? '',
      fajr: clean(timings['Fajr'] as String?),
      dhuhr: clean(timings['Dhuhr'] as String?),
      asr: clean(timings['Asr'] as String?),
      maghrib: clean(timings['Maghrib'] as String?),
      isha: clean(timings['Isha'] as String?),
    );
  } finally {
    Timeline.finishSync(); // guaranteed even if jsonDecode throws
  }
}
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps the free Aladhan REST API for prayer times.
/// Endpoint: https://api.aladhan.com/v1/timingsByCity
///
/// Clean Architecture: This service is a pure data-layer concern.
/// It is consumed by [PrayerTimesNotifier] via the Riverpod provider graph
/// and has zero dependency on Flutter widgets.
class PrayerTimesService {
  PrayerTimesService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.aladhan.com/v1';
  static const _timeout = Duration(seconds: 10);
  static final _log = Logger();

  final http.Client _client;

  /// Fetches today's prayer times for [city] in [country].
  ///
  /// Method 1 = University of Islamic Sciences, Karachi.
  /// Returns a [Map] with keys: Fajr, Dhuhr, Asr, Maghrib, Isha.
  ///
  /// Throws a [PrayerTimesException] on any network or parsing failure.
  Future<PrayerTimesModel> getPrayerTimes({
    String city = 'Karachi',
    String country = 'Pakistan',
    int method = 1,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/timingsByCity?city=${Uri.encodeComponent(city)}'
      '&country=${Uri.encodeComponent(country)}&method=$method',
    );

    _log.d('[PrayerTimes] Fetching → $uri');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      _log.d('[PrayerTimes] HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        throw PrayerTimesException(
          'Unexpected status code: ${response.statusCode}',
        );
      }

      // ── LAYER 1 & 2: Isolate dispatch + main-thread Timeline marker ────────
      // Timeline marker on the MAIN isolate — covers the full round-trip of
      // spawning the background isolate and awaiting its result.
      Timeline.startSync('PrayerTimes_IsolateDispatch');
      try {
        // compute() sends response.body to a background Dart Isolate.
        // _parsePrayerTimesResponse runs JSON decoding + model build there,
        // keeping the UI thread free for the entire parsing duration.
        final model = await compute(_parsePrayerTimesResponse, response.body);
        _log.i('[PrayerTimes] Parsed on background isolate ✓');
        return model;
      } finally {
        Timeline.finishSync(); // guaranteed even if compute() throws
      }
      // ───────────────────────────────────────────────────────────────────────
    } on PrayerTimesException {
      rethrow;
    } catch (e, st) {
      _log.e('[PrayerTimes] Failed to fetch prayer times', error: e, stackTrace: st);
      throw PrayerTimesException('Network error: $e');
    }
  }
}

// ── Value object ─────────────────────────────────────────────────────────────

class PrayerTimesModel {
  const PrayerTimesModel({
    required this.city,
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final String city;
  final String date;
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  /// Convenience list for rendering in order.
  List<PrayerEntry> get entries => [
        PrayerEntry('Fajr', fajr, '🌅'),
        PrayerEntry('Dhuhr', dhuhr, '☀️'),
        PrayerEntry('Asr', asr, '🌤'),
        PrayerEntry('Maghrib', maghrib, '🌇'),
        PrayerEntry('Isha', isha, '🌙'),
      ];
}

class PrayerEntry {
  const PrayerEntry(this.name, this.time, this.emoji);
  final String name;
  final String time;
  final String emoji;
}

// ── Typed exception ───────────────────────────────────────────────────────────

class PrayerTimesException implements Exception {
  const PrayerTimesException(this.message);
  final String message;

  @override
  String toString() => 'PrayerTimesException: $message';
}
