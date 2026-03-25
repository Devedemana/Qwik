import 'package:flutter/material.dart';
import '../models/special.dart';
import '../utils/app_colors.dart';

class SpecialCard extends StatelessWidget {
  final Special special;
  const SpecialCard({super.key, required this.special});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bannerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -10,
            top: -10,
            bottom: -10,
            width: 160,
            child: Image.network(
              special.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.bannerBg,
                    AppColors.bannerBg.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 18, 80, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  special.tag,
                  style: const TextStyle(
                    color: AppColors.subtext,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  special.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  special.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  special.period,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
