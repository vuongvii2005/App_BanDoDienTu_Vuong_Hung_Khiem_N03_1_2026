// Cau truc du lieu san pham trong gio hang.
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_model.dart';
import 'product_variant_model.dart';

class CartItem {
  final String id;
  final String productId;
  final String variantId;
  final String productName;
  final String imageUrl;
  final String storage;
  final String color;
  final int price;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.imageUrl,
    this.storage = '',
    this.color = '',
    required this.price,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  String get selectedStorage => storage;
  String get selectedColor => color;

  factory CartItem.fromProductVariant(
    Product product,
    ProductVariant variant, {
    String id = '',
    int quantity = 1,
  }) {
    return CartItem(
      id: id,
      productId: product.id,
      variantId: variant.id,
      productName: product.name,
      imageUrl:
          variant.imageUrl.isNotEmpty ? variant.imageUrl : product.imageUrl,
      storage: variant.storage,
      color: variant.color,
      price: variant.price,
      quantity: quantity,
    );
  }

  factory CartItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CartItem.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return CartItem(
      id: id ?? _string(map['id']),
      productId: _string(map['productId']),
      variantId: _string(map['variantId']),
      productName: _string(map['productName']),
      imageUrl: _string(map['imageUrl']),
      storage: _string(map['storage'] ?? map['selectedStorage']),
      color: _string(map['color'] ?? map['selectedColor']),
      price: _moneyInt(map['price']),
      quantity: _int(map['quantity'], fallback: 1),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  int get totalPrice => price * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'variantId': variantId,
        'productName': productName,
        'imageUrl': imageUrl,
        'storage': storage,
        'color': color,
        'price': price,
        'quantity': quantity,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  CartItem copyWith({
    String? id,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId,
      variantId: variantId,
      productName: productName,
      imageUrl: imageUrl,
      storage: storage,
      color: color,
      price: price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
