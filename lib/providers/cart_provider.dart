//state giỏ hàng
import 'package:firebase_auth/firebase_auth.dart';
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
  Set<String> _selectedItemIds = <String>{};
  bool _isLoading = false;
  String? _error;
  String? _userId;
  CouponModel? _coupon;

  List<CartItem> get items => List.unmodifiable(_items);
  List<CartItem> get selectedItems => _items
      .where((item) => _selectedItemIds.contains(item.id))
      .toList(growable: false);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  CouponModel? get coupon => _coupon;
  String get couponCode => discount > 0 ? (_coupon?.code ?? '') : '';
  String get discountLabel =>
      couponCode.isEmpty ? 'Giảm giá' : 'Giảm giá ($couponCode)';

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalItems;
  int get selectedItemCount =>
      selectedItems.fold(0, (sum, item) => sum + item.quantity);
  bool get hasSelectedItems => selectedItems.isNotEmpty;

  int get subtotal =>
      selectedItems.fold<int>(0, (sum, item) => sum + item.totalPrice);
  int get discount => _coupon?.discountFor(subtotal) ?? 0;
  int get shippingFee =>
      subtotal >= AppConstants.freeShippingMin || subtotal == 0
          ? 0
          : AppConstants.shippingFee;
  int get totalPrice => subtotal - discount + shippingFee;
  int get total => totalPrice;

  Future<void> loadCart(String userId) async {
    final uid = _currentUserId(userId);
    _userId = uid;
    _setLoading(true);
    _error = null;

    try {
      _items = await _cartService.getCartItems(uid);
      _syncSelectedItems(selectAll: true);
      if (_items.isEmpty) _coupon = null;
    } catch (error) {
      _error = 'Không tải được giỏ hàng';
      _items = <CartItem>[];
      _selectedItemIds = <String>{};
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
    final uid = _currentUserId(userId);
    _userId = uid;
    _error = null;

    try {
      final item = CartItem.fromProductVariant(
        product,
        variant,
        quantity: quantity,
      );
      await _cartService.addItem(uid, item);
      _items = await _cartService.getCartItems(uid);
      _syncSelectedItems();
      _selectItem(product.id, variant.id);
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
    final uid = _currentUserId(userId);
    _userId = uid;
    _error = null;

    try {
      await _cartService.updateQuantity(uid, itemId, quantity);
      _items = await _cartService.getCartItems(uid);
      _syncSelectedItems();
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
    final uid = _currentUserId(userId);
    _userId = uid;
    _error = null;

    try {
      await _cartService.removeItem(uid, itemId);
      _items = await _cartService.getCartItems(uid);
      _syncSelectedItems();
      if (_items.isEmpty) _coupon = null;
    } catch (error) {
      _error = 'Không xóa được sản phẩm';
    }

    notifyListeners();
  }

  Future<void> clearCart(String userId) async {
    final uid = _currentUserId(userId);
    _userId = uid;
    _error = null;

    try {
      await _cartService.clearCart(uid);
      _items = <CartItem>[];
      _selectedItemIds = <String>{};
      _coupon = null;
    } catch (error) {
      _error = 'Không xóa được giỏ hàng';
    }

    notifyListeners();
  }

  void clearLocal() {
    _items = <CartItem>[];
    _selectedItemIds = <String>{};
    _coupon = null;
    notifyListeners();
  }

  void removeItemsLocal(Iterable<String> itemIds) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet();
    if (ids.isEmpty) return;

    _items = _items.where((item) => !ids.contains(item.id)).toList();
    _selectedItemIds.removeAll(ids);
    _syncSelectedItems();
    if (_items.isEmpty) _coupon = null;
    notifyListeners();
  }

  bool isItemSelected(String itemId) => _selectedItemIds.contains(itemId);

  void setItemSelected(String itemId, bool selected) {
    if (itemId.trim().isEmpty) return;

    if (selected) {
      _selectedItemIds.add(itemId);
    } else {
      _selectedItemIds.remove(itemId);
    }
    _syncSelectedItems();
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

  void _selectItem(String productId, String variantId) {
    for (final item in _items) {
      if (item.productId == productId && item.variantId == variantId) {
        _selectedItemIds.add(item.id);
        return;
      }
    }
  }

  void _syncSelectedItems({bool selectAll = false}) {
    final currentIds = _items.map((item) => item.id).toSet();
    if (selectAll) {
      _selectedItemIds = currentIds;
      return;
    }

    _selectedItemIds =
        _selectedItemIds.where((itemId) => currentIds.contains(itemId)).toSet();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _currentUserId(String fallbackUserId) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid.trim() ?? '';
    if (currentUid.isNotEmpty) return currentUid;
    return fallbackUserId.trim();
  }
}
