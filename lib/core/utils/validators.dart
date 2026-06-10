// lib/core/utils/validators.dart
import '../constants/app_constants.dart';

/// All form validation functions.
/// Return null if valid, or an error string if invalid.
class Validators {
  Validators._();

  /// Full name: 2–50 characters, trimmed.
  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'This field is required';
    if (s.length < AppLimits.minNameLength) {
      return 'Name must be at least ${AppLimits.minNameLength} characters';
    }
    if (s.length > AppLimits.maxNameLength) {
      return 'Name must be less than ${AppLimits.maxNameLength} characters';
    }
    return null;
  }

  /// Pakistani mobile number: 03XXXXXXXXX (11 digits).
  static String? phone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'This field is required';
    final re = RegExp(r'^03[0-9]{9}$');
    if (!re.hasMatch(s)) {
      return 'Enter a valid Pakistani number (03XXXXXXXXX)';
    }
    return null;
  }

  /// Provider bio: optional, max 500 chars.
  static String? bio(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.length > AppLimits.maxBioLength) {
      return 'Bio must be less than ${AppLimits.maxBioLength} characters';
    }
    return null;
  }

  /// Full-time rate: 5,000–100,000 PKR/day.
  static String? fullTimeRate(String? v) {
    final s = v?.replaceAll(',', '').trim() ?? '';
    if (s.isEmpty) return 'This field is required';
    final n = int.tryParse(s);
    if (n == null) return 'Enter a valid number';
    if (n < AppLimits.minFullTimeRate) {
      return 'Minimum rate is PKR ${AppLimits.minFullTimeRate}';
    }
    if (n > AppLimits.maxFullTimeRate) {
      return 'Maximum rate is PKR ${AppLimits.maxFullTimeRate}';
    }
    return null;
  }

  /// Part-time rate: 100–2,000 PKR/hr.
  static String? partTimeRate(String? v) {
    final s = v?.replaceAll(',', '').trim() ?? '';
    if (s.isEmpty) return 'This field is required';
    final n = int.tryParse(s);
    if (n == null) return 'Enter a valid number';
    if (n < AppLimits.minPartTimeRate) {
      return 'Minimum rate is PKR ${AppLimits.minPartTimeRate}';
    }
    if (n > AppLimits.maxPartTimeRate) {
      return 'Maximum rate is PKR ${AppLimits.maxPartTimeRate}';
    }
    return null;
  }

  /// Withdrawal amount: 500–100,000 PKR.
  static String? withdrawalAmount(String? v) {
    final n = int.tryParse(v?.replaceAll(',', '') ?? '');
    if (n == null) return 'Enter a valid amount';
    if (n < AppLimits.minWithdrawalAmount) {
      return 'Minimum withdrawal is PKR ${AppLimits.minWithdrawalAmount}';
    }
    if (n > AppLimits.maxWithdrawalAmount) {
      return 'Maximum withdrawal is PKR ${AppLimits.maxWithdrawalAmount}';
    }
    return null;
  }

  /// Chat message: optional but max 1000 chars.
  static String? chatMessage(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.length > AppLimits.maxChatMessageLength) {
      return 'Message too long (max ${AppLimits.maxChatMessageLength} characters)';
    }
    return null;
  }

  /// Rating comment: optional but max 300 chars.
  static String? ratingComment(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.length > AppLimits.maxRatingCommentLength) {
      return 'Comment too long (max ${AppLimits.maxRatingCommentLength} characters)';
    }
    return null;
  }

  /// Required field generic check.
  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  /// Generic string max length.
  static String? maxLength(String? v, int max, {String? label}) {
    if (v != null && v.length > max) {
      return '${label ?? 'Field'} must be less than $max characters';
    }
    return null;
  }

  /// Converts a display phone (03XX XXXXXXX) to stored format (+923XXXXXXXXX).
  static String toStoredPhone(String display) {
    final clean = display.replaceAll(' ', '');
    if (clean.startsWith('03')) {
      return '+92${clean.substring(1)}';
    }
    return clean;
  }
}
