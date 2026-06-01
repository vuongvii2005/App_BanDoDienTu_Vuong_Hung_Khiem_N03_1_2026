class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl = '',
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        icon: map['icon'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
      );
}
