//thao tác giỏ hàng trên Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';

class CartService {
  CartService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _items(String userId) {
    return _firestore.collection('carts').doc(userId).collection('items');
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    _checkUserId(userId);

    final snapshot = await _items(userId).get();
    final items = snapshot.docs.map(CartItem.fromFirestore).toList();
    items.sort((first, second) {
      final firstDate =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return firstDate.compareTo(secondDate);
    });
    return items;
  }

  Future<void> addItem(String userId, CartItem item) async {
    _checkUserId(userId);

    final currentItems = await getCartItems(userId);
    CartItem? existing;
    for (final cartItem in currentItems) {
      final sameProduct = cartItem.productId == item.productId;
      final sameVariant = cartItem.variantId == item.variantId;
      if (sameProduct && sameVariant) {
        existing = cartItem;
        break;
      }
    }

    if (existing != null) {
      await _items(userId).doc(existing.id).update({
        'quantity': existing.quantity + item.quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final docRef = item.id.trim().isEmpty
        ? _items(userId).doc()
        : _items(userId).doc(item.id);

    await docRef.set({
      ...item.copyWith(id: docRef.id).toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    _checkUserId(userId);
    if (itemId.trim().isEmpty) return;

    if (quantity <= 0) {
      await removeItem(userId, itemId);
      return;
    }

    await _items(userId).doc(itemId).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItem(String userId, String itemId) async {
    _checkUserId(userId);
    if (itemId.trim().isEmpty) return;
    await _items(userId).doc(itemId).delete();
  }

  Future<void> clearCart(String userId) async {
    _checkUserId(userId);

    final snapshot = await _items(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _checkUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('Người dùng cần đăng nhập trước khi dùng giỏ hàng.');
    }
  }
}
