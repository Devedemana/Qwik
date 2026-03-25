import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Food image
          Container(
            decoration: BoxDecoration(
              color: AppColors.rust,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
              item.imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 70,
                height: 70,
                color: AppColors.subtext.withValues(alpha: 0.2),
                child: const Icon(Icons.fastfood, color: AppColors.subtext),
              ),
            ),
            ),
          ),
          const SizedBox(width: 12),
          // Name, subtitle, price, and quantity controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtext,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₵${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rust,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls below the price
                Row(
                  children: [
                    _QuantityButton(icon: Icons.remove, onTap: onDecrement),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                    _QuantityButton(icon: Icons.add, onTap: onIncrement),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.rust),
        ),
        child: Icon(icon, size: 12, color: AppColors.rust),
      ),
    );
  }
}
