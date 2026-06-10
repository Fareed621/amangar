// lib/core/services/encryption_service.dart
import 'package:encrypt/encrypt.dart' as enc;
import 'package:logger/logger.dart';

/// AES-256-CBC encryption service for sensitive Firestore fields.
///
/// Fields encrypted at rest:
///   users/{uid}.phone
///   users/{uid}.profilePhoto
///   users/{uid}/providerProfile/profile.portfolioPhotos[]
///   users/{uid}/providerProfile/profile.verificationDocuments.cnicFront
///   users/{uid}/providerProfile/profile.verificationDocuments.cnicBack
///   users/{uid}/providerProfile/profile.verificationDocuments.certification
///
/// KEY ROTATION: All existing encrypted data must be re-encrypted after rotation.
/// Move the key to flutter_dotenv or Firebase Remote Config before production.
class EncryptionService {
  EncryptionService._();

  /// Global singleton instance — accessible without Riverpod ref,
  /// so model fromFirestore() factories can call it directly.
  static final EncryptionService instance = EncryptionService._();

  static final _log = Logger();

  // 32-byte AES-256 key — ROTATE BEFORE PRODUCTION.
  static final _key = enc.Key.fromUtf8(r'AmanGhar$ecureK3yForLocalFirst!!');

  // 16-byte CBC IV.
  static final _iv = enc.IV.fromUtf8('AmanGharIV!2024!');

  static final _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  bool _initialized = false;

  /// Call once at app startup (before runApp) to warm the cipher and log status.
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _log.i('[Encryption] AES-256-CBC service initialized ✓');
  }

  /// Encrypts [plainText] and returns a Base64-encoded cipher string.
  /// Fail-open: returns [plainText] unchanged if encryption throws.
  String encryptData(String plainText) {
    if (plainText.isEmpty) return plainText;
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      _log.e('[Encryption] encryptData failed — returning plaintext', error: e);
      return plainText;
    }
  }

  /// Decrypts a Base64 [cipherText] back to the original string.
  ///
  /// Graceful degradation: if [cipherText] is not valid AES-CBC Base64
  /// (e.g., legacy unencrypted data), it is returned unchanged so the UI
  /// never breaks on old records.
  String decryptData(String cipherText) {
    if (cipherText.isEmpty) return cipherText;
    try {
      final encrypted = enc.Encrypted.fromBase64(cipherText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (_) {
      // Not a valid cipher — treat as unencrypted legacy value.
      return cipherText;
    }
  }

  /// Null-safe convenience wrapper for optional fields.
  String? decryptNullable(String? cipherText) {
    if (cipherText == null) return null;
    return decryptData(cipherText);
  }
}
