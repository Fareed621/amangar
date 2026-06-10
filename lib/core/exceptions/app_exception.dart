// lib/core/exceptions/app_exception.dart

/// Application-level exception that wraps Firebase and other errors
/// into user-friendly messages.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;

  /// Maps Firebase error codes to friendly user messages.
  factory AppException.fromFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const AppException(
          "You don't have permission to do this.",
          code: 'permission-denied',
        );
      case 'not-found':
        return const AppException(
          'The requested data was not found.',
          code: 'not-found',
        );
      case 'unavailable':
        return const AppException(
          'Service unavailable. Please check your connection.',
          code: 'unavailable',
        );
      case 'deadline-exceeded':
        return const AppException(
          'Request timed out. Please try again.',
          code: 'deadline-exceeded',
        );
      case 'already-exists':
        return const AppException(
          'This record already exists.',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const AppException(
          'Too many requests. Please wait a moment.',
          code: 'resource-exhausted',
        );
      case 'cancelled':
        return const AppException(
          'The operation was cancelled.',
          code: 'cancelled',
        );
      case 'unauthenticated':
        return const AppException(
          'Please sign in to continue.',
          code: 'unauthenticated',
        );
      default:
        return const AppException(
          'Something went wrong. Please try again.',
        );
    }
  }
}
