// Thao tac gio hang tren Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';

class CartService {
  CartService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _items(String userId) {
    return _firestore.collection('carts').doc(userId).collection('items');
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    final uid = _currentUserId(fallbackUserId: userId);
    _checkUserId(uid);

    final snapshot = await _items(uid).get();
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
    final uid = _currentUserId(fallbackUserId: userId);
    _checkUserId(uid);

    final currentItems = await getCartItems(uid);
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
      await _items(uid).doc(existing.id).update({
        'quantity': existing.quantity + item.quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final docRef =
        item.id.trim().isEmpty ? _items(uid).doc() : _items(uid).doc(item.id);

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
    final uid = _currentUserId(fallbackUserId: userId);
    _checkUserId(uid);
    if (itemId.trim().isEmpty) return;

    if (quantity <= 0) {
      await removeItem(uid, itemId);
      return;
    }

    await _items(uid).doc(itemId).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItem(String userId, String itemId) async {
    final uid = _currentUserId(fallbackUserId: userId);
    _checkUserId(uid);
    if (itemId.trim().isEmpty) return;
    await _items(uid).doc(itemId).delete();
  }

  Future<void> clearCart(String userId) async {
    final uid = _currentUserId(fallbackUserId: userId);
    _checkUserId(uid);

    final snapshot = await _items(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  String _currentUserId({String fallbackUserId = ''}) {
    final currentUid = _auth.currentUser?.uid.trim() ?? '';
    if (currentUid.isNotEmpty) return currentUid;
    return fallbackUserId.trim();
  }

  void _checkUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'Nguoi dung can dang nhap truoc khi dung gio hang.',
      );
    }
  }
}
