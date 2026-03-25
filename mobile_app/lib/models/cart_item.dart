class CartItem {
  final String name;
  final String subtitle;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}
