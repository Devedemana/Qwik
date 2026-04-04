import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/socket_service.dart';
import '../utils/app_colors.dart';

class OrderTrackingPage extends StatefulWidget {
  final Order order;
  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    SocketService.onOrderStatus((orderId, status, _) {
      if (orderId == _order.id && mounted) {
        // Fetch fresh order so we get the latest data
        _refreshOrder();
      }
    });
  }

  Future<void> _refreshOrder() async {
    try {
      final updated = await OrderService.getOrderById(_order.id);
      if (mounted) setState(() => _order = updated);
    } catch (_) {}
  }

  @override
  void dispose() {
    SocketService.clearOrderStatusCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(_order.status);
    final isReady = _order.status == 'READY';
    final qrData = _order.qrCodeSecret ?? _order.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Tracking', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.rust.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, size: 48, color: AppColors.rust),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _order.cafeteriaName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkBrown),
              ),
            ),
            Center(
              child: Text(
                '₵${_order.totalAmount.toStringAsFixed(2)}  •  ${_order.items.length} item${_order.items.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.subtext, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(_order.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _order.statusDisplay,
                  style: TextStyle(
                    color: _statusColor(_order.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Order Progress',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
            const SizedBox(height: 16),
            ...steps.map((s) => _trackingStep(s.$1, s.$2, s.$3)),
            // QR code — shown when order is READY for pickup
            if (isReady) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Show this to collect your order',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBrown,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF8B3A10),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF8B3A10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${_order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Order items
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Items',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
                  const SizedBox(height: 8),
                  ..._order.items.map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${i.quantity}x ${i.name}',
                                style: const TextStyle(
                                    color: AppColors.darkBrown, fontSize: 13)),
                            Text('₵${(i.price * i.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppColors.subtext, fontSize: 13)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<(String, String, bool)> _buildSteps(String status) {
    final allSteps = ['RECEIVED', 'PREPPING', 'READY', 'COMPLETED'];
    final idx = allSteps.indexOf(status);
    return [
      ('Order Received', 'Your order has been placed', idx >= 0),
      ('Preparing', 'Kitchen is preparing your food', idx >= 1),
      ('Ready for Pickup', 'Your order is ready!', idx >= 2),
      ('Completed', 'Enjoy your meal!', idx >= 3),
    ];
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

  Widget _trackingStep(String title, String subtitle, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? Colors.green : AppColors.subtext.withValues(alpha: 0.4),
                size: 22,
              ),
              Container(width: 2, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: completed ? AppColors.darkBrown : AppColors.subtext,
                    fontSize: 14,
                  )),
              Text(subtitle,
                  style: TextStyle(
                    color: completed
                        ? AppColors.subtext
                        : AppColors.subtext.withValues(alpha: 0.5),
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
