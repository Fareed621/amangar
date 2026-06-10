// lib/core/utils/permission_utils.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for explicit OS-level permission requests.
///
/// Calling these methods before any hardware access ensures the app
/// complies with Android 13+ and iOS 14+ permission models.
///
/// All methods return `true` if permission is granted, `false` otherwise.
class PermissionUtils {
  PermissionUtils._();

  // ── Camera ──────────────────────────────────────────────────────────────────

  /// Requests [Permission.camera].
  ///
  /// If permanently denied, shows a dialog guiding the user to App Settings.
  static Future<bool> requestCamera(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Camera Access Required',
          message:
              'AmanGhar needs access to your camera to capture CNIC photos '
              'for identity verification. Please enable Camera access in '
              'your device Settings.',
        );
      }
      return false;
    }

    status = await Permission.camera.request();

    if (status.isPermanentlyDenied && context.mounted) {
      await _showSettingsDialog(
        context,
        title: 'Camera Access Required',
        message:
            'AmanGhar needs access to your camera to capture CNIC photos '
            'for identity verification. Please enable Camera access in '
            'your device Settings.',
      );
    }

    return status.isGranted;
  }

  // ── Gallery / Photos ────────────────────────────────────────────────────────

  /// Requests [Permission.photos] on iOS 14+ and [Permission.storage]
  /// on Android < 13, automatically selecting the correct permission.
  static Future<bool> requestPhotos(BuildContext context) async {
    // On Android 13+, READ_MEDIA_IMAGES is the correct permission.
    // permission_handler maps Permission.photos → READ_MEDIA_IMAGES on Android 13+
    // and READ_EXTERNAL_STORAGE on older versions automatically.
    var status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Photo Library Access Required',
          message:
              'AmanGhar needs access to your photo library to upload your '
              'profile picture and CNIC documents. Please enable Photos '
              'access in your device Settings.',
        );
      }
      return false;
    }

    status = await Permission.photos.request();

    if (status.isPermanentlyDenied && context.mounted) {
      await _showSettingsDialog(
        context,
        title: 'Photo Library Access Required',
        message:
            'AmanGhar needs access to your photo library to upload your '
            'profile picture and CNIC documents. Please enable Photos '
            'access in your device Settings.',
      );
    }

    return status.isGranted || status.isLimited;
  }

  // ── Notifications ───────────────────────────────────────────────────────────

  /// Requests [Permission.notification] (Android 13+ POST_NOTIFICATIONS).
  /// On older Android and iOS, falls back gracefully.
  static Future<bool> requestNotifications(BuildContext context) async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Notifications Disabled',
          message:
              'Enable notifications to receive booking updates, chat '
              'messages, and important alerts from AmanGhar.',
        );
      }
      return false;
    }
    status = await Permission.notification.request();
    return status.isGranted;
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: Color(0xFF6C63FF)),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
