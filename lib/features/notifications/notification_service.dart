import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/route_names.dart';
import '../../core/providers/auth_provider.dart';

class NotificationService {
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<QuerySnapshot>? _firestoreNotificationSub;
  static final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();
  static final Logger _logger = Logger();
  static DateTime? _appLaunchTime;

  static Future<void> initialize(WidgetRef ref) async {
    _appLaunchTime ??= DateTime.now();
    await _requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    await _localNotifs.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    final userState = ref.read(currentUserProvider);
    final uid = userState.valueOrNull?.uid;
    if (uid != null) {
      await _saveToken(uid);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _saveToken(uid, newToken: token);
      });
      _startNotificationListener(uid);
    } else {
      dispose();
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Cancel existing subscription if any to prevent duplicate notifications
    await _onMessageSubscription?.cancel();
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle background notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final context = AppKeys.navigatorKey.currentContext;
      if (context != null) {
        _handleNotificationTap(message, context);
      }
    });

    // Handle terminated state notification taps
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Delay allows the GoRouter to finish initial redirects (like splash -> home)
      Future.delayed(const Duration(milliseconds: 1000), () {
        final context = AppKeys.navigatorKey.currentContext;
        if (context != null) {
          _handleNotificationTap(initialMessage, context);
        }
      });
    }
  }

  static void dispose() {
    _logger.i('Disposing notification listener');
    _firestoreNotificationSub?.cancel();
    _firestoreNotificationSub = null;
  }

  static void _startNotificationListener(String uid) {
    _firestoreNotificationSub?.cancel();
    
    _logger.i('Starting client-side notification listener for user: $uid');
    
    _firestoreNotificationSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          
          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt != null && _appLaunchTime != null) {
            // Safeguard: only show banner if the notification is newer than app launch time
            if (createdAt.toDate().isAfter(_appLaunchTime!)) {
              _showLocalNotification(data);
            }
          }
        }
      }
    }, onError: (error) {
      _logger.e('Error in notification stream listener', error: error);
    });
  }

  static Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'amanghar_local_notifications',
      'Local Notifications',
      channelDescription: 'Notifications generated client-side',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final title = data['title'] as String? ?? 'New Notification';
    final body = data['body'] as String? ?? '';
    
    final payloadId = data['chatId'] ?? data['bookingId'];
    final payloadType = data['type'];
    final payload = payloadId != null ? '$payloadType:$payloadId' : payloadType;

    await _localNotifs.show(
      id: DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload as String?,
    );
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    final context = AppKeys.navigatorKey.currentContext;
    if (context == null || response.payload == null) return;
    
    final payload = response.payload!;
    if (payload.startsWith('new_message:')) {
      final chatId = payload.split(':')[1];
      context.push('/chat/$chatId');
    }
  }

  static Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _saveToken(String uid, {String? newToken}) async {
    try {
      final token = newToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      _logger.w('Error saving FCM token', error: e);
    }
  }

  static Future<void> clearToken(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (e) {
      _logger.w('Error clearing FCM token', error: e);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final context = AppKeys.navigatorKey.currentContext;
    if (context == null) return;

    // Use an overlay to show notification at the top
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              overlayEntry.remove();
              _handleNotificationTap(message, context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title ?? 'New Notification',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          notification.body ?? '',
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => overlayEntry.remove(),
                  ),
                ],
              ),
            )
                .animate()
                .slideY(
                    begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut)
                .fadeIn(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void _handleNotificationTap(
      RemoteMessage message, BuildContext context) {
    final data = message.data;
    final type = data['type'] as String?;
    final id = data['bookingId'] ?? data['chatId'];

    if (type == 'new_message' && id != null) {
      context.push(
        '/chat/$id',
        extra: {
          'otherName': data['otherName'] ?? 'Chat',
          'otherUid': data['otherUid'] ?? '',
          'otherPhoto': data['otherPhoto'],
        },
      );
      return;
    }

    final route = _getNavigationRoute(data);
    if (route != null) {
      context.push(route);
    }
  }

  static String? _getNavigationRoute(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['bookingId'] ?? data['chatId'];

    switch (type) {
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_completed':
        return id != null ? '/bookings/$id' : '/bookings';
      case 'new_message':
        return id != null ? '/chat/$id' : '/chat';
      case 'verification_approved':
      case 'verification_rejected':
        return RouteNames.verification;
      case 'withdrawal_success':
      case 'withdrawal_failed':
        return RouteNames.earnings;
      case 'rating_received':
        return id != null ? '/bookings/$id' : '/bookings';
      default:
        return null;
    }
  }
}
