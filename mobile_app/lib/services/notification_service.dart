import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import 'socket_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String? orderId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.orderId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        time: time,
        isRead: isRead ?? this.isRead,
        orderId: orderId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'isRead': isRead,
        'orderId': orderId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        time: DateTime.parse(j['time'] as String),
        isRead: j['isRead'] as bool? ?? false,
        orderId: j['orderId'] as String?,
      );
}

class NotificationService extends ChangeNotifier {
  static const _prefsKey = 'app_notifications';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<AppNotification> _notifications = [];
  int _localNotifId = 0;

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    await _load();
    await _initLocalNotifications();
  }

  // ── Local notifications (native banners) ──────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _localNotifications.initialize(initSettings);
  }

  Future<void> _showBanner(String title, String body) async {
    // Native banners only on mobile/desktop — skip on web
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'qwik_orders',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _localNotifications.show(_localNotifId++, title, body, details);
  }

  // ── Socket connection ──────────────────────────────────────────────────────

  void connectSocket(String userId) {
    SocketService.connect(
      userId: userId,
      onOrderStatus: (orderId, status, cafeteriaName) {
        _handleOrderStatus(orderId, status, cafeteriaName);
      },
    );
  }

  void disconnectSocket() => SocketService.disconnect();

  void _handleOrderStatus(String orderId, String status, String cafeteriaName) {
    final label = cafeteriaName.isNotEmpty ? cafeteriaName : 'your cafeteria';
    String title, body;
    switch (status) {
      case 'PREPPING':
        title = 'Order is being prepared!';
        body = '$label has started preparing your order.';
        break;
      case 'READY':
        title = 'Your order is ready!';
        body = 'Head to $label to pick up your order.';
        break;
      case 'COMPLETED':
        title = 'Order completed';
        body = 'Your order at $label was marked as completed. Enjoy!';
        break;
      case 'CANCELLED':
        title = 'Order cancelled';
        body = 'Your order at $label was cancelled.';
        break;
      default:
        title = 'Order update';
        body = 'Your order status changed to $status.';
    }

    final notification = AppNotification(
      id: '${orderId}_${status}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      time: DateTime.now(),
      orderId: orderId,
    );

    _addNotification(notification);
    _showBanner(title, body);
  }

  // ── Called right after placing an order ───────────────────────────────────

  Future<void> orderPlaced(Order order) async {
    final label = order.cafeteriaName.isNotEmpty ? order.cafeteriaName : 'the cafeteria';
    const title = 'Order placed!';
    final body = 'Your order at $label has been received. We\'ll notify you when it\'s ready.';
    await _addNotification(AppNotification(
      id: '${order.id}_placed_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      time: DateTime.now(),
      orderId: order.id,
    ));
    await _showBanner(title, body);
  }

  // ── Read state ─────────────────────────────────────────────────────────────

  Future<void> markAllRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _save();
  }

  Future<void> markRead(String id) async {
    _notifications =
        _notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _notifications = [];
    notifyListeners();
    await _save();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _addNotification(AppNotification n) async {
    _notifications.add(n);
    notifyListeners();
    await _save();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _notifications = list
          .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_notifications.map((n) => n.toJson()).toList()));
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }
}
