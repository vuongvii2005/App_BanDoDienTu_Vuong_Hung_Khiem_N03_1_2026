//state giỏ hàng
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;

  List<CartItem> _items = <CartItem>[];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalItems;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get discount => subtotal >= 1000 ? subtotal * 0.1 : 0;
  double get shippingFee => subtotal >= 500 || subtotal == 0 ? 0 : 15;
  double get totalPrice => subtotal - discount + shippingFee;
  double get total => totalPrice;

  Future<void> loadCart(String userId) async {
    _userId = userId;
    _setLoading(true);
    _error = null;

    try {
      _items = await _cartService.getCartItems(userId);
    } catch (error) {
      _error = 'Không tải được giỏ hàng';
      _items = <CartItem>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(
    String userId,
    Product product,
    String selectedStorage,
    String selectedColor, {
    int quantity = 1,
  }) async {
    _userId = userId;
    _error = null;

    try {
      final item = CartItem.fromProduct(
        product,
        quantity: quantity,
        selectedStorage: selectedStorage,
        selectedColor: selectedColor,
      );
      await _cartService.addItem(userId, item);
      _items = await _cartService.getCartItems(userId);
    } catch (error) {
      _error = 'Cần đăng nhập để thêm vào giỏ hàng';
    }

    notifyListeners();
  }

  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    _error = null;

    try {
      await _cartService.updateQuantity(userId, itemId, quantity);
      _items = await _cartService.getCartItems(userId);
    } catch (error) {
      _error = 'Không cập nhật được số lượng';
    }

    notifyListeners();
  }

  Future<void> increaseQuantity(String userId, String itemId) async {
    final item = _findItem(itemId);
    if (item == null) return;
    await updateQuantity(userId, itemId, item.quantity + 1);
  }

  Future<void> decreaseQuantity(String userId, String itemId) async {
    final item = _findItem(itemId);
    if (item == null) return;
    await updateQuantity(userId, itemId, item.quantity - 1);
  }

  Future<void> removeItem(String userId, String itemId) async {
    _error = null;

    try {
      await _cartService.removeItem(userId, itemId);
      _items = await _cartService.getCartItems(userId);
    } catch (error) {
      _error = 'Không xóa được sản phẩm';
    }

    notifyListeners();
  }

  Future<void> clearCart(String userId) async {
    _error = null;

    try {
      await _cartService.clearCart(userId);
      _items = <CartItem>[];
    } catch (error) {
      _error = 'Không xóa được giỏ hàng';
    }

    notifyListeners();
  }

  void clearLocal() {
    _items = <CartItem>[];
    notifyListeners();
  }

  CartItem? _findItem(String itemId) {
    for (final item in _items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
