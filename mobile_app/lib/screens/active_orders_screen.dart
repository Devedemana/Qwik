import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../Frontend/oder_tracking.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final orders = await OrderService.getUserOrders();
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text('My Orders',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                      ? const Center(
                          child: Text('No orders yet', style: TextStyle(color: AppColors.subtext)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _OrderCard(order: _orders[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingPage(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.rust.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: AppColors.rust),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.cafeteriaName,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}  •  ₵${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.subtext, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(order.statusDisplay,
                  style: TextStyle(
                      color: _statusColor(order.status), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING_PAYMENT': return Colors.orange;
      case 'RECEIVED': return Colors.blue;
      case 'PREPPING': return Colors.amber.shade700;
      case 'READY': return Colors.green;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return AppColors.subtext;
    }
  }
}
