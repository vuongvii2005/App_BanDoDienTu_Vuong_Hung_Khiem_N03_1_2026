class Category {
  final String id;
  final String name;
  final String icon;
  final String? description;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  // Convert from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'], // biến này là string có thể null nên không cần gán giá trị mặc định
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  @override
  String toString() => 'Category(id: $id, name: $name, icon: $icon)';
}
