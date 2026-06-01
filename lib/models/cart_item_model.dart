//cấu trúc dữ liệu sản phẩm trong giỏ hàng
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_model.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String selectedStorage;
  final String selectedColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.selectedStorage = '',
    this.selectedColor = '',
    this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromProduct(
    Product product, {
    String id = '',
    int quantity = 1,
    String selectedStorage = '',
    String selectedColor = '',
  }) {
    return CartItem(
      id: id,
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      quantity: quantity,
      selectedStorage: selectedStorage,
      selectedColor: selectedColor,
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
      productName: _string(map['productName']),
      imageUrl: _string(map['imageUrl']),
      price: _double(map['price']),
      quantity: _int(map['quantity'], fallback: 1),
      selectedStorage: _string(map['selectedStorage']),
      selectedColor: _string(map['selectedColor']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'selectedStorage': selectedStorage,
        'selectedColor': selectedColor,
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
      productName: productName,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
      selectedStorage: selectedStorage,
      selectedColor: selectedColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static double _double(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
