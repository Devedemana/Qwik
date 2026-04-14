import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this runs.
  // flutter_local_notifications handles display automatically on Android 13+.
}

class FcmService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission (iOS + Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications channel for foreground display
    const androidChannel = AndroidNotificationChannel(
      'qwik_orders',
      'Order Updates',
      description: 'Notifications about your Qwik orders',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(initSettings);

    // Show notification when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    // Register token with our backend
    await _registerToken();

    // Re-register if token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _registerToken());
  }

  static Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await ApiService.post('/api/user/fcm-token', {'token': token}, auth: true);
    } catch (_) {
      // Not critical — token can be registered next launch
    }
  }
}
