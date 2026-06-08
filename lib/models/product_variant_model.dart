import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariant {
  final String id;
  final String productId;
  final String storage;
  final String color;
  final int price;
  final int oldPrice;
  final int stock;
  final String sku;
  final String imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductVariant({
    required this.id,
    required this.productId,
    this.storage = '',
    this.color = '',
    required this.price,
    this.oldPrice = 0,
    this.stock = 0,
    this.sku = '',
    this.imageUrl = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? productId,
  }) {
    final parentProductId = doc.reference.parent.parent?.id;
    return ProductVariant.fromMap(
      doc.data() ?? <String, dynamic>{},
      id: doc.id,
      productId: productId ?? parentProductId,
    );
  }

  factory ProductVariant.fromMap(
    Map<String, dynamic> map, {
    String? id,
    String? productId,
  }) {
    return ProductVariant(
      id: id ?? _string(map['id']),
      productId: productId ?? _string(map['productId']),
      storage: _string(map['storage']),
      color: _string(map['color']),
      price: _moneyInt(map['price']),
      oldPrice: _moneyInt(map['oldPrice']),
      stock: _int(map['stock']),
      sku: _string(map['sku']),
      imageUrl: _string(map['imageUrl']),
      isActive: map.containsKey('isActive') ? _bool(map['isActive']) : true,
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'storage': storage,
        'color': color,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'sku': sku,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String get displayStorage => storage.trim().isEmpty ? 'Mặc định' : storage;
  String get displayColor => color.trim().isEmpty ? 'Mặc định' : color;
  bool get inStock => stock > 0;

  static String _string(dynamic value) => value?.toString() ?? '';

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

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
