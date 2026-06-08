//state đơn hàng
import 'package:firebase_auth/firebase_auth.dart';
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
  List<OrderModel> _adminOrders = <OrderModel>[];
  bool _isLoading = false;
  bool _isAdminLoading = false;
  String? _error;
  String? _adminError;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<OrderModel> get adminOrders => List.unmodifiable(_adminOrders);
  bool get isLoading => _isLoading;
  bool get isAdminLoading => _isAdminLoading;
  String? get error => _error;
  String? get adminError => _adminError;

  Future<void> loadOrders(String userId) async {
    final uid = _currentUserId(userId);
    _setLoading(true);
    _error = null;

    try {
      _orders = await _orderService.getOrdersByUser(uid);
    } catch (error) {
      _error = 'Không tải được đơn hàng';
      _orders = <OrderModel>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAdminOrders() async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      _adminOrders = await _orderService.getAllOrders();
    } catch (error) {
      _adminError = 'Không tải được danh sách đơn hàng';
      _adminOrders = <OrderModel>[];
    } finally {
      _setAdminLoading(false);
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
    final uid = _currentUserId(userId);
    if (uid.isEmpty) {
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
        userId: uid,
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
      await _cartService.removeItems(
        uid,
        items.map((item) => item.id),
      );
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

  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _orderService.updateOrderStatus(orderId, status.name);
      _updateCachedOrderStatus(_adminOrders, orderId, status);
      _updateCachedOrderStatus(_orders, orderId, status);
      return true;
    } catch (error) {
      _adminError = 'Không cập nhật được trạng thái đơn hàng';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAdminLoading(bool value) {
    _isAdminLoading = value;
    notifyListeners();
  }

  String _currentUserId(String fallbackUserId) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid.trim() ?? '';
    if (currentUid.isNotEmpty) return currentUid;
    return fallbackUserId.trim();
  }

  void _updateCachedOrderStatus(
    List<OrderModel> orders,
    String orderId,
    OrderStatus status,
  ) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final order = orders[index];
    orders[index] = OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      subtotal: order.subtotal,
      discount: order.discount,
      shippingFee: order.shippingFee,
      total: order.total,
      couponCode: order.couponCode,
      paymentMethod: order.paymentMethod,
      shippingAddress: order.shippingAddress,
      phone: order.phone,
      status: status,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
