//cấu trúc dữ liệu đơn hàng
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cart_item_model.dart';

enum OrderStatus { pending, confirmed, shipping, completed, cancelled }

class OrderItem {
  final String productId;
  final String variantId;
  final String productName;
  final String imageUrl;
  final String storage;
  final String color;
  final int price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.imageUrl,
    this.storage = '',
    this.color = '',
    required this.price,
    required this.quantity,
  });

  String get selectedStorage => storage;
  String get selectedColor => color;

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      variantId: item.variantId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      storage: item.storage,
      color: item.color,
      price: item.price,
      quantity: item.quantity,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: _string(map['productId']),
      variantId: _string(map['variantId']),
      productName: _string(map['productName']),
      imageUrl: _string(map['imageUrl']),
      storage: _string(map['storage'] ?? map['selectedStorage']),
      color: _string(map['color'] ?? map['selectedColor']),
      price: _moneyInt(map['price']),
      quantity: _int(map['quantity'], fallback: 1),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'variantId': variantId,
        'productName': productName,
        'imageUrl': imageUrl,
        'storage': storage,
        'color': color,
        'price': price,
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final int subtotal;
  final int discount;
  final int shippingFee;
  final int total;
  final String couponCode;
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
    this.couponCode = '',
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
      subtotal: _moneyInt(map['subtotal']),
      discount: _moneyInt(map['discount']),
      shippingFee: _moneyInt(map['shippingFee']),
      total: _moneyInt(map['total']),
      couponCode: _string(map['couponCode']),
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
        'couponCode': couponCode,
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

int _moneyInt(dynamic value) {
  final amount = _moneyAmount(value);
  final sign = amount < 0 ? -1 : 1;
  final absoluteAmount = amount.abs();

  if (absoluteAmount == 0) return 0;
  if (absoluteAmount >= 100000) return amount.round();
  if (absoluteAmount >= 10000) return sign * (absoluteAmount * 1000).round();
  return sign * (absoluteAmount * 25000).round();
}

double _moneyAmount(dynamic value) {
  if (value is num) return value.toDouble();
  final text = value?.toString().trim() ?? '';
  final parsed = num.tryParse(text.replaceAll(',', ''));
  if (parsed != null) return parsed.toDouble();
  return double.tryParse(text.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
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
