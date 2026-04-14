class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> dietaryLifestyle;
  final List<String> allergies;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.dietaryLifestyle = const [],
    this.allergies = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      dietaryLifestyle: (json['dietaryLifestyle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
