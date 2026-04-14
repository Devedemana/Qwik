import '../widgets/cart_item_card.dart';

class CartItem implements CartItemLike {
  @override
  final String name;
  @override
  final String subtitle;
  @override
  final double price;
  @override
  final String imagePath;
  @override
  int quantity;

  CartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}
