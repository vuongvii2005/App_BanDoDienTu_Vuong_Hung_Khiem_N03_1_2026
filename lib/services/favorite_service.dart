import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/favorite_model.dart';

class FavoriteService {
  FavoriteService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _favorites(String uid) {
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  Future<List<FavoriteModel>> getFavorites(String uid) async {
    _checkUid(uid);
    await _ensureUserProfile(uid);

    final snapshot = await _favorites(uid).get();
    final favorites = snapshot.docs.map(FavoriteModel.fromFirestore).toList();
    favorites.sort((first, second) {
      final firstDate =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondDate.compareTo(firstDate);
    });
    return favorites;
  }

  Future<bool> isFavorite(String uid, String productId) async {
    _checkUid(uid);
    _checkProductId(productId);
    await _ensureUserProfile(uid);

    final doc = await _favorites(uid).doc(productId).get();
    return doc.exists;
  }

  Future<void> addFavorite(String uid, String productId) async {
    _checkUid(uid);
    _checkProductId(productId);
    await _ensureUserProfile(uid);

    await _favorites(uid).doc(productId).set({
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite(String uid, String productId) async {
    _checkUid(uid);
    _checkProductId(productId);
    await _ensureUserProfile(uid);

    await _favorites(uid).doc(productId).delete();
  }

  Future<bool> toggleFavorite(String uid, String productId) async {
    _checkUid(uid);
    _checkProductId(productId);
    await _ensureUserProfile(uid);

    final docRef = _favorites(uid).doc(productId);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      return false;
    }

    await docRef.set({
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  void _checkUid(String uid) {
    if (uid.trim().isEmpty) {
      throw ArgumentError('User id is required for favorites.');
    }
  }

  void _checkProductId(String productId) {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product id is required for favorites.');
    }
  }

  Future<void> _ensureUserProfile(String uid) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data() ?? <String, dynamic>{};

    if (doc.exists &&
        data['role'] is String &&
        data['isActive'] is bool &&
        data['uid'] == uid) {
      return;
    }

    await docRef.set({
      'uid': uid,
      if (!doc.exists || data['fullName'] is! String)
        'fullName': user.displayName?.trim() ?? user.email?.trim() ?? '',
      if (!doc.exists || data['email'] is! String)
        'email': user.email?.trim() ?? '',
      if (!doc.exists || data['phone'] is! String) 'phone': '',
      if (!doc.exists || data['avatarUrl'] is! String) 'avatarUrl': '',
      if (!doc.exists || data['address'] is! String) 'address': '',
      if (!doc.exists || data['role'] is! String) 'role': 'user',
      if (!doc.exists || data['isActive'] is! bool) 'isActive': true,
      if (!doc.exists) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
