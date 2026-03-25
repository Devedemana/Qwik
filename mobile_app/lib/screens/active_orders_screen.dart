import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Cart',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }
}
