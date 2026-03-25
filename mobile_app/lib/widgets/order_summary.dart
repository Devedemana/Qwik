import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double taxes;
  final double delivery;
  final double total;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.taxes,
    required this.delivery,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', subtotal),
          const SizedBox(height: 10),
          _buildRow('Taxes', taxes),
          const SizedBox(height: 10),
          _buildRow('Delivery', delivery),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildRow('Total', total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 16 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: isBold ? AppColors.darkBrown : AppColors.subtext,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('₵${amount.toStringAsFixed(2)}',
          style: style.copyWith(color: AppColors.darkBrown)),
      ],
    );
  }
}
