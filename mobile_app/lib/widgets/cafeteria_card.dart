import 'package:flutter/material.dart';
import '../models/cafeteria.dart';
import '../utils/app_colors.dart';

class CafeteriaCard extends StatelessWidget {
  final Cafeteria cafeteria;
  const CafeteriaCard({super.key, required this.cafeteria});

  Color _mealPeriodColor(String period) {
    switch (period) {
      case 'BREAKFAST': return Colors.orange.shade700;
      case 'LUNCH_DINNER': return Colors.green.shade600;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              color: AppColors.rust,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    cafeteria.imageAsset.isNotEmpty ? cafeteria.imageAsset : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.rust.withValues(alpha: 0.5)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    cafeteria.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mealPeriodColor(cafeteria.mealPeriod).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cafeteria.mealPeriodLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x33000000), blurRadius: 6),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
