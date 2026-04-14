import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/app_colors.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onAddToCart;

  const FoodCard({super.key, required this.item, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.rust,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: AppColors.rust.withValues(alpha: 0.6)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipOval(
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                  if (item.isExpress)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, color: Colors.white, size: 10),
                            SizedBox(width: 2),
                            Text('Express', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
              child: Column(
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                  if (item.allergenTags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: item.allergenTags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade300.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    item.priceDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodDetailSheet(item: item, onAddToCart: onAddToCart),
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 100,
        color: Colors.white24,
        child: const Icon(Icons.restaurant, color: Colors.white, size: 36),
      );
}

class _FoodDetailSheet extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onAddToCart;
  const _FoodDetailSheet({required this.item, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
          const SizedBox(height: 4),
          Text(item.description, style: const TextStyle(fontSize: 14, color: AppColors.subtext)),
          const SizedBox(height: 6),
          Text(item.priceDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.rust)),
          const SizedBox(height: 16),

          if (item.dietaryTags.isNotEmpty) ...[
            const Text('Dietary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: item.dietaryTags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white)),
                backgroundColor: AppColors.rust,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 14),
          ],

          if (item.allergenTags.isNotEmpty) ...[
            const Text('Allergens', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: item.allergenTags.map((tag) => Chip(
                avatar: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white)),
                backgroundColor: Colors.red.shade400,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 14),
          ],

          if (item.ingredients.isNotEmpty) ...[
            const Text('Ingredients', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
            const SizedBox(height: 6),
            ...item.ingredients.map((ing) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 5, color: AppColors.subtext),
                  const SizedBox(width: 8),
                  Text(ing, style: const TextStyle(fontSize: 14, color: AppColors.darkBrown)),
                ],
              ),
            )),
          ],

          if (item.isExpress) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: AppColors.orange, size: 16),
                  SizedBox(width: 4),
                  Text('Express Meal — Ready in under 10 mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.orange)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAddToCart?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
