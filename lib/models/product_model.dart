// Cau truc du lieu chung cua san pham.
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String description;
  final String imageUrl;
  final List<String> images;
  final int minPrice;
  final int maxPrice;
  final int totalStock;
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
    this.description = '',
    required this.imageUrl,
    this.images = const [],
    this.minPrice = 0,
    this.maxPrice = 0,
    this.totalStock = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Compatibility getters for old list/card UI while variants are introduced.
  int get price => minPrice;
  int get oldPrice => 0;
  int get stock => totalStock;
  List<String> get storageOptions => const <String>[];
  List<String> get colorOptions => const <String>[];
  bool get hasPriceRange => maxPrice > minPrice;

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? categoryId,
    String? description,
    String? imageUrl,
    List<String>? images,
    int? minPrice,
    int? maxPrice,
    int? totalStock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      totalStock: totalStock ?? this.totalStock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Product.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    final imageUrl = _string(map['imageUrl'] ?? map['image']);
    final images = _stringList(map['images']);
    final minPrice = _moneyInt(map['minPrice'] ?? map['price']);
    final maxPrice = _moneyInt(map['maxPrice'] ?? map['price']);

    return Product(
      id: id ?? _string(map['id']),
      name: _string(map['name']),
      brand: _string(map['brand']),
      categoryId: _string(map['categoryId'] ?? map['category']),
      description: _string(map['description']),
      imageUrl: imageUrl,
      images: images.isEmpty && imageUrl.isNotEmpty ? [imageUrl] : images,
      minPrice: minPrice,
      maxPrice: maxPrice == 0 ? minPrice : maxPrice,
      totalStock: _int(map['totalStock'] ?? map['stock']),
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
        'description': description,
        'imageUrl': imageUrl,
        'images': images,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'totalStock': totalStock,
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

  static int _moneyInt(dynamic value) {
    final amount = _moneyAmount(value);
    final sign = amount < 0 ? -1 : 1;
    final absoluteAmount = amount.abs();

    if (absoluteAmount == 0) return 0;
    if (absoluteAmount >= 100000) return amount.round();
    if (absoluteAmount >= 10000) return sign * (absoluteAmount * 1000).round();
    return sign * (absoluteAmount * 25000).round();
  }

  static double _moneyAmount(dynamic value) {
    if (value is num) return value.toDouble();
    final text = value?.toString().trim() ?? '';
    final parsed = num.tryParse(text.replaceAll(',', ''));
    if (parsed != null) return parsed.toDouble();
    return double.tryParse(text.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
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
