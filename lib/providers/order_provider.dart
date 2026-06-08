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
    required int subtotal,
    required int discount,
    required int shippingFee,
    required int total,
    String couponCode = '',
    required String paymentMethod,
    required Map<String, String> shippingInfo,
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

      // Build full address from shipping info
      final city = shippingInfo['city'] ?? '';
      final district = shippingInfo['district'] ?? '';
      final detail = shippingInfo['detail'] ?? '';
      final legacyAddress = shippingInfo['address'] ?? '';
      final shippingAddress =
          (detail.isNotEmpty ? '$detail, $district, $city' : legacyAddress)
              .replaceAll(RegExp(r', +'), ', ')
              .replaceAll(RegExp(r'^, |, $'), '');

      final order = OrderModel(
        id: orderId,
        userId: userId,
        items: items.map(OrderItem.fromCartItem).toList(),
        subtotal: subtotal,
        discount: discount,
        shippingFee: shippingFee,
        total: total,
        couponCode: couponCode,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        phone: shippingInfo['phone'] ?? '',
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final savedId = await _orderService.createOrder(order);
      final createdOrderId = savedId.trim().isEmpty ? order.id : savedId;
      await _cartService.clearCart(userId);
      _orders.insert(0, order);
      return createdOrderId;
    } catch (error) {
      _error = 'Không tạo được đơn hàng';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final id = orderId.trim();
    if (id.isEmpty) return null;

    final cachedOrder = getCachedOrderById(id);
    if (cachedOrder != null) {
      return cachedOrder;
    }

    try {
      final order = await _orderService.getOrderById(id);
      if (order == null) return null;

      final existingIndex = _orders.indexWhere((item) => item.id == order.id);
      if (existingIndex == -1) {
        _orders.insert(0, order);
      } else {
        _orders[existingIndex] = order;
      }

      notifyListeners();
      return order;
    } catch (error) {
      _error = 'Khong tai duoc chi tiet don hang';
      notifyListeners();
      return null;
    }
  }

  OrderModel? getCachedOrderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderModel? getById(String id) => getCachedOrderById(id);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
