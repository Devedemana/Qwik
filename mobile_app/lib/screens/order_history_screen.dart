import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../Frontend/oder_tracking.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await OrderService.getUserOrders();
      // Sort newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order History', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: AppColors.subtext),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.subtext)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rust, foregroundColor: Colors.white),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.subtext),
                          SizedBox(height: 12),
                          Text('No orders yet', style: TextStyle(color: AppColors.subtext, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderHistoryCard(
                        order: _orders[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderTrackingPage(order: _orders[i])),
                        ).then((_) => _load()),
                      ),
                    ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderHistoryCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.cafeteriaName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkBrown),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'}  •  ₵${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.subtext, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style: const TextStyle(color: AppColors.subtext, fontSize: 12),
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                order.items.map((i) => '${i.quantity}× ${i.name}').join(', '),
                style: const TextStyle(color: AppColors.darkBrown, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('View details', style: TextStyle(color: AppColors.rust, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.rust, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today, ${_timeStr(dt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_timeStr(dt)}';
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}, ${_timeStr(dt)}';
  }

  String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(),
        style: TextStyle(color: _color(), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _color() {
    switch (status) {
      case 'PENDING_PAYMENT': return Colors.orange;
      case 'RECEIVED': return Colors.blue;
      case 'PREPPING': return Colors.amber.shade700;
      case 'READY': return Colors.green;
      case 'COMPLETED': return Colors.green.shade800;
      case 'CANCELLED': return Colors.red;
      default: return AppColors.subtext;
    }
  }

  String _label() {
    switch (status) {
      case 'PENDING_PAYMENT': return 'Pending';
      case 'RECEIVED': return 'Received';
      case 'PREPPING': return 'Preparing';
      case 'READY': return 'Ready';
      case 'COMPLETED': return 'Completed';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }
}
