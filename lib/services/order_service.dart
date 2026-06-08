// Thao tac collection orders.
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
      await _incrementCouponUsedCount(order.couponCode);
    } catch (_) {
      // Coupon usage count is best-effort; order creation should not fail here.
    }

    return docRef.id;
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
}
