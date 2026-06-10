// lib/core/utils/formatters.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// All display formatters for price, date, time, phone, and rating.
class Formatters {
  Formatters._();

  static final _priceFormat = NumberFormat('#,###', 'en_US');

  /// "PKR 20,000"
  static String formatPrice(int pkr) => 'PKR ${_priceFormat.format(pkr)}';

  /// "PKR 20,000/day"
  static String formatPricePerDay(int pkr) =>
      'PKR ${_priceFormat.format(pkr)}/day';

  /// "PKR 800/hr"
  static String formatPricePerHour(int pkr) =>
      'PKR ${_priceFormat.format(pkr)}/hr';

  /// "15 Jun 2026"
  static String formatDate(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('d MMM yyyy').format(ts.toDate().toLocal());
  }

  /// "15 Jun"
  static String formatDateShort(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('d MMM').format(ts.toDate().toLocal());
  }

  /// "9:00 AM" — converts HH:MM 24-hour to 12-hour.
  static String formatTime(String time24h) {
    try {
      final parts = time24h.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, h, m);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time24h;
    }
  }

  /// "15 Jun 2026, 9:00 AM"
  static String formatDateTime(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('d MMM yyyy, h:mm a').format(ts.toDate().toLocal());
  }

  /// WhatsApp-style relative time: "2 minutes ago", "1 hour ago",
  /// "Yesterday", "15 Jun"
  static String formatRelativeTime(Timestamp? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final dt = ts.toDate().toLocal();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    // Same year: show "15 Jun", otherwise "15 Jun 2025"
    if (dt.year == now.year) return DateFormat('d MMM').format(dt);
    return DateFormat('d MMM yyyy').format(dt);
  }

  /// Converts "+923001234567" → "0300 1234567"
  static String formatPhoneDisplay(String stored) {
    String s = stored;
    if (s.startsWith('+92')) {
      s = '0${s.substring(3)}';
    }
    if (s.length >= 5) {
      return '${s.substring(0, 4)} ${s.substring(4)}';
    }
    return s;
  }

  /// "4.3" — one decimal place.
  static String formatRating(double r) => r.toStringAsFixed(1);

  /// "8 hours" — parses HH:MM strings.
  static String formatDuration(String start, String end) {
    try {
      final sp = start.split(':');
      final ep = end.split(':');
      final startMins = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      final endMins = int.parse(ep[0]) * 60 + int.parse(ep[1]);
      final mins = endMins - startMins;
      if (mins <= 0) return '0 hours';
      final h = mins ~/ 60;
      final m = mins % 60;
      if (m == 0) return '$h hour${h == 1 ? '' : 's'}';
      return '$h hr $m min';
    } catch (_) {
      return '';
    }
  }

  /// Time-based greeting.
  /// 05–11 → morning, 12–16 → afternoon, 17–20 → evening, 21–04 → night
  static String timeGreeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h <= 11) return 'Good morning';
    if (h >= 12 && h <= 16) return 'Good afternoon';
    if (h >= 17 && h <= 20) return 'Good evening';
    return 'Good night';
  }
}
