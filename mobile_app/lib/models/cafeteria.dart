class Cafeteria {
  final String id;
  final String name;
  final String imageAsset;
  final bool isOpen;
  final String capacityStatus;
  final String mealPeriod;       // BREAKFAST | LUNCH_DINNER | CLOSED
  final String mealPeriodLabel;  // Human-readable

  const Cafeteria({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.isOpen = true,
    this.capacityStatus = 'GREEN',
    this.mealPeriod = 'CLOSED',
    this.mealPeriodLabel = 'Closed',
  });

  factory Cafeteria.fromJson(Map<String, dynamic> json) {
    return Cafeteria(
      id: json['id'] as String,
      name: json['name'] as String,
      imageAsset: json['imageUrl'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? true,
      capacityStatus: json['capacityStatus'] as String? ?? 'GREEN',
      mealPeriod: json['mealPeriod'] as String? ?? 'CLOSED',
      mealPeriodLabel: json['mealPeriodLabel'] as String? ?? 'Closed',
    );
  }
}
