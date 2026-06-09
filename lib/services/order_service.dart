// Thao tac collection orders.
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Future<String> createOrder(OrderModel order) async {
    final uid = _currentUserId(fallbackUserId: order.userId);
    if (uid.isEmpty) {
      throw ArgumentError('User id cannot be empty for orders.');
    }

    final docRef =
        order.id.trim().isEmpty ? _orders.doc() : _orders.doc(order.id);

    await docRef.set({
      ...order.toMap(),
      'id': docRef.id,
      'userId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await _decreaseStockForOrder(order.items);
    } catch (_) {
      // Stock update is best-effort on the client; order creation must not fail.
    }

    try {
      await _incrementCouponUsedCount(order.couponCode);
    } catch (_) {
      // Coupon usage count is best-effort; order creation should not fail here.
    }

    return docRef.id;
  }

  Future<void> _decreaseStockForOrder(List<OrderItem> items) async {
    final productQuantities = <String, int>{};
    final variantQuantities = <String, _VariantStockChange>{};

    for (final item in items) {
      final productId = item.productId.trim();
      final variantId = item.variantId.trim();
      final quantity = item.quantity;
      if (productId.isEmpty || quantity <= 0) continue;

      productQuantities.update(
        productId,
        (current) => current + quantity,
        ifAbsent: () => quantity,
      );

      if (variantId.isNotEmpty) {
        final key = '$productId::$variantId';
        final existing = variantQuantities[key];
        variantQuantities[key] = existing == null
            ? _VariantStockChange(
                productId: productId,
                variantId: variantId,
                quantity: quantity,
              )
            : existing.copyWith(quantity: existing.quantity + quantity);
      }
    }

    if (productQuantities.isEmpty && variantQuantities.isEmpty) return;

    final now = DateTime.now();

    for (final entry in productQuantities.entries) {
      final ref = _firestore.collection('products').doc(entry.key);
      final snapshot = await ref.get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) continue;

      final stockField =
          data.containsKey('totalStock') ? 'totalStock' : 'stock';
      final currentStock = _int(data[stockField]);
      final updates = <String, dynamic>{};

      if (currentStock > 0) {
        updates[stockField] = (currentStock - entry.value).clamp(
          0,
          currentStock,
        );
      }

      final dealQuantity = _activeDealQuantityForProduct(
        items: items,
        productId: entry.key,
        productData: data,
        now: now,
      );
      if (dealQuantity > 0) {
        updates['dealSold'] = FieldValue.increment(dealQuantity);
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _safeStockUpdate(ref, updates);
      }
    }

    for (final change in variantQuantities.values) {
      final ref = _firestore
          .collection('products')
          .doc(change.productId)
          .collection('variants')
          .doc(change.variantId);
      final snapshot = await ref.get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) continue;

      final currentStock = _int(data['stock']);
      if (currentStock <= 0) continue;

      await _safeStockUpdate(ref, {
        'stock': (currentStock - change.quantity).clamp(0, currentStock),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _safeStockUpdate(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> updates,
  ) async {
    try {
      await ref.update(updates);
    } catch (error, stackTrace) {
      developer.log(
        'Khong cap nhat duoc ton kho: ${ref.path}',
        name: 'OrderService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  int _activeDealQuantityForProduct({
    required List<OrderItem> items,
    required String productId,
    required Map<String, dynamic> productData,
    required DateTime now,
  }) {
    final isHotDeal = productData['isHotDeal'] == true;
    final salePrice = _nullableInt(productData['salePrice']);
    final price = _int(productData['minPrice'] ?? productData['price']);
    final startAt = _date(productData['dealStartAt']);
    final endAt = _date(productData['dealEndAt']);
    final started = startAt == null || !startAt.isAfter(now);
    final notExpired = endAt == null || endAt.isAfter(now);

    if (!isHotDeal ||
        salePrice == null ||
        salePrice >= price ||
        !started ||
        !notExpired) {
      return 0;
    }

    return items
        .where((item) =>
            item.productId.trim() == productId && item.price == salePrice)
        .fold<int>(0, (total, item) => total + item.quantity);
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final uid = _currentUserId(fallbackUserId: userId);
    if (uid.isEmpty) return <OrderModel>[];

    final snapshot = await _orders.where('userId', isEqualTo: uid).get();
    final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
    orders.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return orders;
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _orders.get();
    final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
    orders.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return orders;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return null;

    final doc = await _orders.doc(id).get();
    if (!doc.exists) return null;

    return OrderModel.fromFirestore(doc);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.trim().isEmpty) return;

    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _incrementCouponUsedCount(String couponCode) async {
    final code = couponCode.trim().toUpperCase();
    if (code.isEmpty) return;

    final snapshot = await _firestore
        .collection('coupons')
        .where('code', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;

    await snapshot.docs.first.reference.update({
      'usedCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _currentUserId({String fallbackUserId = ''}) {
    final currentUid = _auth.currentUser?.uid.trim() ?? '';
    if (currentUid.isNotEmpty) return currentUid;
    return fallbackUserId.trim();
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _VariantStockChange {
  final String productId;
  final String variantId;
  final int quantity;

  const _VariantStockChange({
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  _VariantStockChange copyWith({int? quantity}) {
    return _VariantStockChange(
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
    );
  }
}
