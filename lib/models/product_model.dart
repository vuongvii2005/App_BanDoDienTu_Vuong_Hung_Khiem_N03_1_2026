//cấu trúc dữ liệu sản phẩm
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final double price;
  final double oldPrice;
  final String description;
  final String imageUrl;
  final List<String> images;
  final List<String> storageOptions;
  final List<String> colorOptions;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.brand = '',
    required this.categoryId,
    required this.price,
    this.oldPrice = 0,
    this.description = '',
    required this.imageUrl,
    this.images = const [],
    this.storageOptions = const [],
    this.colorOptions = const [],
    this.stock = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Product.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    final imageUrl = _string(map['imageUrl'] ?? map['image']);
    final images = _stringList(map['images']);

    return Product(
      id: id ?? _string(map['id']),
      name: _string(map['name']),
      brand: _string(map['brand']),
      categoryId: _string(map['categoryId'] ?? map['category']),
      price: _double(map['price']),
      oldPrice: _double(map['oldPrice']),
      description: _string(map['description']),
      imageUrl: imageUrl,
      images: images.isEmpty && imageUrl.isNotEmpty ? [imageUrl] : images,
      storageOptions: _stringList(map['storageOptions'] ?? map['storage']),
      colorOptions: _stringList(map['colorOptions'] ?? map['colors']),
      stock: _int(map['stock']),
      rating: _double(map['rating']),
      reviewCount: _int(map['reviewCount']),
      isFeatured: _bool(map['isFeatured']),
      isActive: map.containsKey('isActive') ? _bool(map['isActive']) : true,
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromMap(json);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'categoryId': categoryId,
        'price': price,
        'oldPrice': oldPrice,
        'description': description,
        'imageUrl': imageUrl,
        'images': images,
        'storageOptions': storageOptions,
        'colorOptions': colorOptions,
        'stock': stock,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Map<String, dynamic> toJson() => toMap();

  static String _string(dynamic value) => value?.toString() ?? '';

  static double _double(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }
    return <String>[];
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
