// lib/core/services/prayer_times_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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

      final body = jsonDecode(response.body) as Map<String, dynamic>;

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

      // Strip seconds suffix from times like "05:12 (PKT)"
      String _clean(String? raw) =>
          (raw ?? '--:--').split(' ').first.trim();

      return PrayerTimesModel(
        city: city,
        date: readable ?? '',
        fajr: _clean(timings['Fajr'] as String?),
        dhuhr: _clean(timings['Dhuhr'] as String?),
        asr: _clean(timings['Asr'] as String?),
        maghrib: _clean(timings['Maghrib'] as String?),
        isha: _clean(timings['Isha'] as String?),
      );
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
  List<_PrayerEntry> get entries => [
        _PrayerEntry('Fajr', fajr, '🌅'),
        _PrayerEntry('Dhuhr', dhuhr, '☀️'),
        _PrayerEntry('Asr', asr, '🌤'),
        _PrayerEntry('Maghrib', maghrib, '🌇'),
        _PrayerEntry('Isha', isha, '🌙'),
      ];
}

class _PrayerEntry {
  const _PrayerEntry(this.name, this.time, this.emoji);
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
