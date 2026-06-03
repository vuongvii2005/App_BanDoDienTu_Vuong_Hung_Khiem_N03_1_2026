//thao tác collection orders
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Future<String> createOrder(OrderModel order) async {
    final docRef =
        order.id.trim().isEmpty ? _orders.doc() : _orders.doc(order.id);

    await docRef.set({
      ...order.toMap(),
      'id': docRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    if (userId.trim().isEmpty) return <OrderModel>[];

    final snapshot = await _orders.where('userId', isEqualTo: userId).get();
    final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
    orders.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return orders;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    if (orderId.trim().isEmpty) return null;

    final doc = await _orders.doc(orderId).get();
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
}
