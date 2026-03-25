import 'package:flutter/material.dart';
import '../models/cafeteria.dart';
import '../utils/app_colors.dart';

class CafeteriaCard extends StatelessWidget {
  final Cafeteria cafeteria;
  const CafeteriaCard({super.key, required this.cafeteria});

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
                    cafeteria.imageAsset,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.rust.withValues(alpha: 0.5)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    cafeteria.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
