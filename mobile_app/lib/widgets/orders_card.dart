import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/cart_service.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary.dart';
import '../Frontend/payment.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: cart.isEmpty
                      ? _buildEmpty(context)
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          children: [
                            ...cart.entries.map((entry) => CartItemCard(
                                  item: _toCartItem(entry),
                                  onIncrement: () => cart.increment(entry.item.id),
                                  onDecrement: () => cart.decrement(entry.item.id),
                                )),
                            const SizedBox(height: 24),
                            OrderSummary(
                              subtotal: cart.subtotal,
                              taxes: cart.taxes,
                              delivery: cart.deliveryFee,
                              total: cart.total,
                            ),
                          ],
                        ),
                ),
                if (!cart.isEmpty) _buildCheckoutButton(context, cart),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 46),
          const Expanded(
            child: Center(
              child: Text(
                'My Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ),
          Consumer<CartService>(
            builder: (context, cart, _) => cart.isEmpty
                ? const SizedBox(width: 46)
                : _CircleButton(
                    icon: Icons.delete_outline,
                    onTap: () => cart.clear(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.subtext.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: AppColors.subtext),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu to get started',
            style: TextStyle(fontSize: 14, color: AppColors.subtext),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartService cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: cart,
                child: const PaymentPage(),
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Checkout  •  ₵${cart.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Bridge CartEntry → CartItem for CartItemCard
  dynamic _toCartItem(CartEntry entry) => _CartItemAdapter(entry);
}

// Adapter so CartItemCard still works via the CartItemLike interface
class _CartItemAdapter implements CartItemLike {
  final CartEntry entry;
  _CartItemAdapter(this.entry);
  @override String get name => entry.item.name;
  @override String get subtitle => entry.item.description;
  @override double get price => entry.item.price;
  @override String get imagePath => entry.item.imageUrl;
  @override int get quantity => entry.quantity;
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
        width: 46,
        height: 46,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.darkBrown, size: 20),
      ),
    );
  }
}
