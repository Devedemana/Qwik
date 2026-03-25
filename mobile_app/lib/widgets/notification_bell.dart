import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.darkBrown,
            size: 22,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
