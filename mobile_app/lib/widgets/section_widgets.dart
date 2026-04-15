import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

Widget buildSectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkBrown,
        letterSpacing: -0.3,
      ),
    ),
  );
}

Widget buildSectionRow(String label, {VoidCallback? onSeeMore}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrown,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onSeeMore,
          child: const Text(
            'See more',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.subtext,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
