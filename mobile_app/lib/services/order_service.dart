import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  static Future<Order> createOrder({
    required String cafeteriaId,
    required DateTime pickupWindow,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await ApiService.post(
      '/api/orders',
      {
        'cafeteriaId': cafeteriaId,
        'pickupWindow': pickupWindow.toIso8601String(),
        'items': items,
      },
      auth: true,
    );
    return Order.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<List<Order>> getUserOrders() async {
    final res = await ApiService.get('/api/orders', auth: true);
    final data = res['data'] as List<dynamic>;
    return data.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Order> getOrderById(String id) async {
    final res = await ApiService.get('/api/orders/$id', auth: true);
    return Order.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<Order> cancelOrder(String id) async {
    final res = await ApiService.patch('/api/orders/$id/cancel', {}, auth: true);
    return Order.fromJson(res['data'] as Map<String, dynamic>);
  }
}
