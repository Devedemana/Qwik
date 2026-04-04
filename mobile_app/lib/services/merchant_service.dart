import 'api_service.dart';
import '../models/order.dart';

class MerchantService {
  /// Fetch active orders for a cafeteria (RECEIVED / PREPPING / READY)
  static Future<List<Order>> getQueue(String cafeteriaId) async {
    final res = await ApiService.get(
      '/api/merchant/orders/$cafeteriaId',
      auth: true,
    );
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Advance an order to the next status
  static Future<Order> advanceOrder(String orderId, String newStatus) async {
    final res = await ApiService.patch(
      '/api/merchant/orders/$orderId',
      {'status': newStatus},
      auth: true,
    );
    return Order.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Toggle a menu item's availability
  static Future<void> toggleInventory(String itemId, bool isAvailable) async {
    await ApiService.put(
      '/api/merchant/inventory',
      {'itemId': itemId, 'isAvailable': isAvailable},
      auth: true,
    );
  }

  /// Update cafeteria capacity status: GREEN | YELLOW | RED
  static Future<void> updateCapacityStatus(
      String cafeteriaId, String status) async {
    await ApiService.patch(
      '/api/merchant/status',
      {'cafeteriaId': cafeteriaId, 'status': status},
      auth: true,
    );
  }

  /// Add a new menu item (ADMIN only)
  static Future<void> addMenuItem({
    required String cafeteriaId,
    required String name,
    required double price,
    required String category,
    String? description,
    List<String>? allergenTags,
    String? imageUrl,
  }) async {
    await ApiService.post(
      '/api/merchant/menu',
      {
        'cafeteriaId': cafeteriaId,
        'name': name,
        'price': price,
        'category': category,
        if (description != null) 'description': description,
        if (allergenTags != null) 'allergenTags': allergenTags,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      auth: true,
    );
  }

  /// Update an existing menu item (ADMIN only)
  static Future<void> updateMenuItem(String id, Map<String, dynamic> fields) async {
    await ApiService.patch('/api/merchant/menu/$id', fields, auth: true);
  }

  /// Delete a menu item (ADMIN only)
  static Future<void> deleteMenuItem(String id) async {
    await ApiService.delete('/api/merchant/menu/$id', auth: true);
  }
}
