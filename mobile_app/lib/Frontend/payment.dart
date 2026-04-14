import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import 'oder_tracking.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'Mobile Money';
  bool _isPlacing = false;

  final _methods = ['Mobile Money', 'Meal Plan', 'Cash On Pickup'];

  // Descriptions shown below each option
  static const _descriptions = {
    'Mobile Money': 'You will be redirected to dial *170# to complete payment via MTN MoMo.',
    'Meal Plan': 'Pay using your Ashesi meal plan at the cafeteria counter.',
    'Cash On Pickup': 'Pay cash when you collect your order at the cafeteria.',
  };

  Future<void> _placeOrder(CartService cart) async {
    if (cart.cafeteriaId == null) return;

    if (_selectedMethod == 'Mobile Money') {
      await _launchMoMoDial(cart);
      return;
    }

    // Meal Plan and Cash On Pickup — place order, pay at cafeteria
    setState(() => _isPlacing = true);
    try {
      final order = await OrderService.createOrder(
        cafeteriaId: cart.cafeteriaId!,
        pickupWindow: DateTime.now().add(const Duration(minutes: 30)),
        items: cart.toOrderItems(),
      );

      if (mounted) {
        await context.read<NotificationService>().orderPlaced(order);
      }

      cart.clear();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingPage(order: order)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _launchMoMoDial(CartService cart) async {
    // Show confirmation dialog before placing order + opening dialer
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mobile Money Payment'),
        content: Text(
          'Your order of ₵${cart.total.toStringAsFixed(2)} will be placed.\n\n'
          'You will then be directed to dial *170# to complete payment via MTN MoMo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rust),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPlacing = true);
    try {
      final order = await OrderService.createOrder(
        cafeteriaId: cart.cafeteriaId!,
        pickupWindow: DateTime.now().add(const Duration(minutes: 30)),
        items: cart.toOrderItems(),
      );

      if (mounted) {
        await context.read<NotificationService>().orderPlaced(order);
      }

      cart.clear();

      if (!mounted) return;
      await _showMoMoNetworkSheet();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingPage(order: order)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  String _buttonLabel() {
    switch (_selectedMethod) {
      case 'Mobile Money':
        return 'Place Order & Pay via MoMo';
      case 'Meal Plan':
        return 'Place Order — Pay at Cafeteria';
      case 'Cash On Pickup':
        return 'Place Order — Pay at Cafeteria';
      default:
        return 'Place Order';
    }
  }

  Future<void> _showMoMoNetworkSheet() async {
    const networks = [
      ('MTN MoMo', '*170#'),
      ('Telecel Cash', '*110#'),
      ('AirtelTigo Money', '*100#'),
    ];
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order placed!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Open your dialer and complete MoMo payment.',
                style: TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 16),
            ...networks.map((n) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone, color: Color(0xFF8B3A10)),
                  title: Text(n.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(n.$2,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF8B3A10))),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final uri = Uri(scheme: 'tel', path: n.$2);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                )),
            const Divider(),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Center(
                  child: Text('Pay later',
                      style: TextStyle(color: Colors.black54))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Payment Method", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._methods.map((m) => _paymentOption(m)),
            const SizedBox(height: 16),
            if (cart.cafeteriaName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'From: ${cart.cafeteriaName}',
                  style: const TextStyle(color: AppColors.subtext, fontSize: 13),
                ),
              ),
            const Spacer(),
            _priceRow("Subtotal", '₵${cart.subtotal.toStringAsFixed(2)}'),
            _priceRow("Taxes & fees", '₵${cart.taxes.toStringAsFixed(2)}'),
            _priceRow("Delivery Fee", '₵${cart.deliveryFee.toStringAsFixed(2)}'),
            const Divider(),
            _priceRow("Total", '₵${cart.total.toStringAsFixed(2)}', bold: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isPlacing ? null : () => _placeOrder(cart),
                child: _isPlacing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_buttonLabel(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String title) {
    final selected = _selectedMethod == title;
    final description = _descriptions[title] ?? '';
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.rust : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.rust : AppColors.subtext,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.rust : Colors.black87)),
                  if (selected) ...[
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(
                            color: AppColors.subtext, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String title, String price, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(price, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
