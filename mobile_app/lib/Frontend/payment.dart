import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/cafeteria_service.dart';
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
  DateTime _selectedPickup = DateTime.now().add(const Duration(minutes: 30));
  String _capacityStatus = 'GREEN'; // fetched from cafeteria

  // Generate 15-min slots from now+15min to now+2h
  List<DateTime> get _pickupSlots {
    final now = DateTime.now();
    return List.generate(8, (i) => now.add(Duration(minutes: 15 + i * 15)));
  }

  bool _isOffPeak(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute;
    final totalMins = hour * 60 + min;
    // Off-peak: before 11:30 or after 13:30
    return totalMins < 11 * 60 + 30 || totalMins > 13 * 60 + 30;
  }

  @override
  void initState() {
    super.initState();
    _selectedPickup = _pickupSlots.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCapacity());
  }

  Future<void> _loadCapacity() async {
    final cart = context.read<CartService>();
    if (cart.cafeteriaId == null) return;
    try {
      final cafeterias = await CafeteriaService.listCafeterias();
      final match = cafeterias.where((c) => c.id == cart.cafeteriaId).firstOrNull;
      if (mounted && match != null) setState(() => _capacityStatus = match.capacityStatus);
    } catch (_) {}
  }

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
        pickupWindow: _selectedPickup,
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
        pickupWindow: _selectedPickup,
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
            _buildPickupWindowSection(),
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

  Widget _buildPickupWindowSection() {
    final capacityColor = _capacityStatus == 'GREEN'
        ? Colors.green
        : _capacityStatus == 'YELLOW'
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Pickup Window',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkBrown)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: capacityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 7, height: 7,
                      decoration: BoxDecoration(color: capacityColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(_capacityStatus,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: capacityColor)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _pickupSlots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final slot = _pickupSlots[i];
              final selected = _selectedPickup == slot;
              final offPeak = _isOffPeak(slot);
              final h = slot.hour.toString().padLeft(2, '0');
              final m = slot.minute.toString().padLeft(2, '0');
              return GestureDetector(
                onTap: () => setState(() => _selectedPickup = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 66,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.darkBrown : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: selected ? AppColors.darkBrown : Colors.black12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$h:$m',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: selected ? Colors.white : AppColors.darkBrown)),
                      if (offPeak)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: selected ? Colors.green.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Off-Peak',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.greenAccent : Colors.green.shade700)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _capacityStatus == 'RED'
              ? 'Cafeteria is very busy — consider an off-peak slot'
              : _capacityStatus == 'YELLOW'
                  ? 'Cafeteria is moderately busy'
                  : 'Cafeteria has good availability',
          style: TextStyle(fontSize: 11, color: capacityColor),
        ),
        const SizedBox(height: 12),
      ],
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
