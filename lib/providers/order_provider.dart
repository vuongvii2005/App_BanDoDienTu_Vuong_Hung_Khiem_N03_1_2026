//state đơn hàng
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    OrderService? orderService,
    CartService? cartService,
  })  : _orderService = orderService ?? OrderService(),
        _cartService = cartService ?? CartService();

  final OrderService _orderService;
  final CartService _cartService;

  List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _orders = await _orderService.getOrdersByUser(userId);
    } catch (error) {
      _error = 'Không tải được đơn hàng';
      _orders = <OrderModel>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required String paymentMethod,
    required String shippingAddress,
    required String phone,
  }) async {
    if (userId.trim().isEmpty) {
      _error = 'Cần đăng nhập để đặt hàng';
      notifyListeners();
      return null;
    }

    if (items.isEmpty) {
      _error = 'Giỏ hàng đang trống';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _error = null;

    try {
      final orderId = 'TS${DateTime.now().millisecondsSinceEpoch}';
      final order = OrderModel(
        id: orderId,
        userId: userId,
        items: items.map(OrderItem.fromCartItem).toList(),
        subtotal: subtotal,
        discount: discount,
        shippingFee: shippingFee,
        total: total,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        phone: phone,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final savedId = await _orderService.createOrder(order);
      await _cartService.clearCart(userId);
      _orders.insert(0, order);
      return savedId;
    } catch (error) {
      _error = 'Không tạo được đơn hàng';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  OrderModel? getOrderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderModel? getById(String id) => getOrderById(id);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
