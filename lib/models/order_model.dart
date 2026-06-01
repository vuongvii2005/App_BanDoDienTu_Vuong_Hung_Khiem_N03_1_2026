//cấu trúc dữ liệu đơn hàng
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cart_item_model.dart';

enum OrderStatus { pending, confirmed, shipping, completed, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String selectedStorage;
  final String selectedColor;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.selectedStorage = '',
    this.selectedColor = '',
  });

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      price: item.price,
      quantity: item.quantity,
      selectedStorage: item.selectedStorage,
      selectedColor: item.selectedColor,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: _string(map['productId']),
      productName: _string(map['productName']),
      imageUrl: _string(map['imageUrl']),
      price: _double(map['price']),
      quantity: _int(map['quantity'], fallback: 1),
      selectedStorage: _string(map['selectedStorage']),
      selectedColor: _string(map['selectedColor']),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'selectedStorage': selectedStorage,
        'selectedColor': selectedColor,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String paymentMethod;
  final String shippingAddress;
  final String phone;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.shippingFee = 0,
    required this.total,
    required this.paymentMethod,
    required this.shippingAddress,
    this.phone = '',
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return OrderModel.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawItems = map['items'];
    final items = rawItems is Iterable
        ? rawItems
            .whereType<Map>()
            .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : <OrderItem>[];

    return OrderModel(
      id: id ?? _string(map['id']),
      userId: _string(map['userId']),
      items: items,
      subtotal: _double(map['subtotal']),
      discount: _double(map['discount']),
      shippingFee: _double(map['shippingFee']),
      total: _double(map['total']),
      paymentMethod: _string(map['paymentMethod']),
      shippingAddress: _string(map['shippingAddress']),
      phone: _string(map['phone']),
      status: _status(map['status']),
      createdAt: _date(map['createdAt']) ?? DateTime.now(),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'shippingFee': shippingFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'shippingAddress': shippingAddress,
        'phone': phone,
        'status': status.name,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800);
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3);
      case OrderStatus.shipping:
        return const Color(0xFF9C27B0);
      case OrderStatus.completed:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }

  static OrderStatus _status(dynamic value) {
    final text = value?.toString() ?? '';
    return OrderStatus.values.firstWhere(
      (status) => status.name == text,
      orElse: () => OrderStatus.pending,
    );
  }
}

typedef Order = OrderModel;

String _string(dynamic value) => value?.toString() ?? '';

double _double(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _date(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
