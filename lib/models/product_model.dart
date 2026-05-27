class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final List<String> storage; // ['256GB', '512GB', '1TB']
  final List<String> colors; // ['Titan Tự nhiên', 'Titan Đen', ...]
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.rating = 0,
    this.reviewCount = 0,
    required this.imageUrl,
    this.description = '',
    this.storage = const [],
    this.colors = const [],
    this.isFeatured = false,
  });
}
