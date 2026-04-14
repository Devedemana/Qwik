import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/app_colors.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onAddToCart;

  const FoodCard({super.key, required this.item, this.onAddToCart});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FoodDetailSheet(item: item, onAddToCart: onAddToCart),
    );
  }

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
                  if (item.dietaryTags.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.dietaryTags.first,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
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
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: item.imageUrl.isNotEmpty
                ? Image.network(item.imageUrl, height: 180, width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder())
                : _imgPlaceholder(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(item.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
              ),
              Text(item.priceDisplay,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.rust)),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.description, style: const TextStyle(color: AppColors.subtext, fontSize: 14)),
          ],
          if (item.dietaryTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('Dietary'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6,
                children: item.dietaryTags.map((t) => _tag(t, Colors.green.shade600)).toList()),
          ],
          if (item.allergenTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('Allergens'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6,
                children: item.allergenTags.map((t) => _tag(t, Colors.orange.shade700)).toList()),
          ],
          if (item.ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('Ingredients'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6,
                children: item.ingredients.map((i) => _tag(i, AppColors.subtext)).toList()),
          ],
          if (item.allergenTags.isEmpty && item.dietaryTags.isEmpty && item.ingredients.isEmpty) ...[
            const SizedBox(height: 16),
            const Text('No nutritional info available yet.',
                style: TextStyle(color: AppColors.subtext, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          if (onAddToCart != null)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onAddToCart!();
                },
                child: Text('Add to Cart  •  ${item.priceDisplay}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkBrown));

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _imgPlaceholder() => Container(
        height: 180,
        color: AppColors.rust.withValues(alpha: 0.1),
        child: const Center(child: Icon(Icons.restaurant, size: 60, color: AppColors.subtext)),
      );
}
