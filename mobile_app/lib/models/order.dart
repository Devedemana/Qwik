class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class Order {
  final String id;
  final String cafeteriaId;
  final String cafeteriaName;
  final double totalAmount;
  final String status;
  final bool isPaid;
  final DateTime pickupWindow;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? qrCodeSecret;

  const Order({
    required this.id,
    required this.cafeteriaId,
    required this.cafeteriaName,
    required this.totalAmount,
    required this.status,
    required this.isPaid,
    required this.pickupWindow,
    required this.createdAt,
    required this.items,
    this.qrCodeSecret,
  });

  String get statusDisplay {
    switch (status) {
      case 'PENDING_PAYMENT':
        return 'Pending Payment';
      case 'RECEIVED':
        return 'Order Received';
      case 'PREPPING':
        return 'Preparing';
      case 'READY':
        return 'Ready for Pickup';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final cafeteria = json['cafeteria'] as Map<String, dynamic>?;
    return Order(
      id: json['id'] as String,
      cafeteriaId: json['cafeteriaId'] as String,
      cafeteriaName: cafeteria?['name'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      isPaid: json['isPaid'] as bool? ?? false,
      pickupWindow: DateTime.parse(json['pickupWindow'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      qrCodeSecret: json['qrCodeSecret'] as String?,
    );
  }
}
