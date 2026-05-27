import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../utils/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = List.from(MockData.orders);

  List<Order> get orders => _orders;

  Order? getById(String id) =>
      _orders.firstWhere((o) => o.id == id, orElse: () => _orders.first);

  String placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required String paymentMethod,
    required String shippingAddress,
  }) {
    final orderId =
        'TS${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final order = Order(
      id: orderId,
      items: List.from(items),
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      total: total,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    notifyListeners();
    return orderId;
  }
}
