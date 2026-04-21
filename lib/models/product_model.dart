class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String image;
  final List<String>? images;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFavorite;
  final String? brand;
  final Map<String, dynamic>? specifications;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.image,
    this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFavorite = false,
    this.brand,
    this.specifications,
  });

  // Convert from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] ?? '',
      image: json['image'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      stock: json['stock'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      brand: json['brand'],
      specifications: json['specifications'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'image': image,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isFavorite': isFavorite,
      'brand': brand,
      'specifications': specifications,
    };
  }

  // Copy with method for updating specific fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? image,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isFavorite,
    String? brand,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
      brand: brand ?? this.brand,
      specifications: specifications ?? this.specifications,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}
