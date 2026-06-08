//state giỏ hàng
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/coupon_model.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import '../services/cart_service.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;

  List<CartItem> _items = <CartItem>[];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  CouponModel? _coupon;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  CouponModel? get coupon => _coupon;
  String get couponCode => discount > 0 ? (_coupon?.code ?? '') : '';
  String get discountLabel =>
      couponCode.isEmpty ? 'Giảm giá' : 'Giảm giá ($couponCode)';

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalItems;

  int get subtotal => _items.fold<int>(0, (sum, item) => sum + item.totalPrice);
  int get discount => _coupon?.discountFor(subtotal) ?? 0;
  int get shippingFee =>
      subtotal >= AppConstants.freeShippingMin || subtotal == 0
          ? 0
          : AppConstants.shippingFee;
  int get totalPrice => subtotal - discount + shippingFee;
  int get total => totalPrice;

  Future<void> loadCart(String userId) async {
    _userId = userId;
    _setLoading(true);
    _error = null;

    try {
      _items = await _cartService.getCartItems(userId);
      if (_items.isEmpty) _coupon = null;
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
    ProductVariant variant, {
    int quantity = 1,
  }) async {
    _userId = userId;
    _error = null;

    try {
      final item = CartItem.fromProductVariant(
        product,
        variant,
        quantity: quantity,
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
      _coupon = null;
    } catch (error) {
      _error = 'Không xóa được giỏ hàng';
    }

    notifyListeners();
  }

  void clearLocal() {
    _items = <CartItem>[];
    _coupon = null;
    notifyListeners();
  }

  void applyCoupon(CouponModel coupon) {
    _coupon = coupon;
    notifyListeners();
  }

  void clearCoupon() {
    _coupon = null;
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
