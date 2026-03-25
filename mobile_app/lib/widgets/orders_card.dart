// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/cart_item.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> items = [
    CartItem(name: 'Yakisoba Noodles', subtitle: 'Noodle with Pork',      price: 12, imagePath: 'assets/yakisoba.jpg',  quantity: 2),
    CartItem(name: 'Stir-Fried Chicken', subtitle: 'Chicken with Peanuts', price: 12, imagePath: 'assets/chicken.jpg',   quantity: 1),
    CartItem(name: 'Prawn Fried Rice',  subtitle: 'Fried Rice with Prawns',price: 12, imagePath: 'assets/prawn.jpg',     quantity: 3),
  ];

  double get subtotal => items.fold(0, (s, i) => s + i.price * i.quantity);
  double get taxes    => subtotal * 0.044;
  double get delivery => 6.0;
  double get total    => subtotal + taxes + delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  ...items.map((item) => CartItemCard(
                    item: item,
                    onIncrement: () => setState(() => item.quantity++),
                    onDecrement: () => setState(() {
                      if (item.quantity > 1) item.quantity--;
                    }),
                  )),
                  const SizedBox(height: 24),
                  OrderSummary(
                    subtotal: subtotal,
                    taxes: taxes,
                    delivery: delivery,
                    total: total,
                  ),
                ],
              ),
            ),
            _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text('My Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrown,
                )),
            ),
          ),
          _CircleButton(icon: Icons.more_vert, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Checkout',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.darkBrown, size: 20),
      ),
    );
  }
}
