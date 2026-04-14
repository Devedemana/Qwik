class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String cafeteriaId;
  final bool isAvailable;
  final List<String> allergenTags;
  final List<String> dietaryTags;
  final bool isExpress;
  final List<String> ingredients;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.cafeteriaId,
    this.isAvailable = true,
    this.allergenTags = const [],
    this.dietaryTags = const [],
    this.isExpress = false,
    this.ingredients = const [],
  });

  String get priceDisplay => '₵${price.toStringAsFixed(2)}';

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      cafeteriaId: json['cafeteriaId'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      allergenTags: (json['allergenTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dietaryTags: (json['dietaryTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isExpress: json['isExpress'] as bool? ?? false,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
