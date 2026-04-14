import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

typedef OrderStatusCallback = void Function(String orderId, String status, String cafeteriaName);

class SocketService {
  static io.Socket? _socket;
  static OrderStatusCallback? _onOrderStatus;
  // Secondary listener for screens that need live updates (e.g. OrderTrackingPage)
  static OrderStatusCallback? _onOrderStatusExtra;

  static void onOrderStatus(OrderStatusCallback cb) {
    _onOrderStatusExtra = cb;
  }

  static void clearOrderStatusCallback() {
    _onOrderStatusExtra = null;
  }

  static void connect({required String userId, OrderStatusCallback? onOrderStatus}) {
    _onOrderStatus = onOrderStatus;

    _socket = io.io(
      ApiService.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      // Join the user's personal room to receive order push events
      _socket!.emit('join_user', userId);
    });

    _socket!.on('order_status_update', (data) {
      if (data is Map) {
        final orderId = data['orderId'] as String? ?? '';
        final status = data['status'] as String? ?? '';
        final cafeteriaName = data['cafeteriaName'] as String? ?? '';
        _onOrderStatus?.call(orderId, status, cafeteriaName);
        _onOrderStatusExtra?.call(orderId, status, cafeteriaName);
      }
    });

    _socket!.onDisconnect((_) {});
    _socket!.onError((_) {});
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  static bool get isConnected => _socket?.connected ?? false;
}
