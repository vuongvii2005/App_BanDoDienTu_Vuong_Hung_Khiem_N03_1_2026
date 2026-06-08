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
    final userUid = _currentUid(fallbackUid: uid);
    _checkUid(userUid);
    await _ensureUserProfileBestEffort(userUid);

    final snapshot = await _favorites(userUid).get();
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
    final userUid = _currentUid(fallbackUid: uid);
    _checkUid(userUid);
    _checkProductId(productId);
    await _ensureUserProfileBestEffort(userUid);

    final doc = await _favorites(userUid).doc(productId).get();
    return doc.exists;
  }

  Future<void> addFavorite(String uid, String productId) async {
    final userUid = _currentUid(fallbackUid: uid);
    _checkUid(userUid);
    _checkProductId(productId);
    await _ensureUserProfileBestEffort(userUid);

    await _favorites(userUid).doc(productId).set({
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite(String uid, String productId) async {
    final userUid = _currentUid(fallbackUid: uid);
    _checkUid(userUid);
    _checkProductId(productId);
    await _ensureUserProfileBestEffort(userUid);

    await _favorites(userUid).doc(productId).delete();
  }

  Future<bool> toggleFavorite(String uid, String productId) async {
    final userUid = _currentUid(fallbackUid: uid);
    _checkUid(userUid);
    _checkProductId(productId);
    await _ensureUserProfileBestEffort(userUid);

    final docRef = _favorites(userUid).doc(productId);
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

  String _currentUid({String fallbackUid = ''}) {
    final currentUid = _auth.currentUser?.uid.trim() ?? '';
    if (currentUid.isNotEmpty) return currentUid;
    return fallbackUid.trim();
  }

  Future<void> _ensureUserProfile(String uid) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data() ?? <String, dynamic>{};

    if (doc.exists &&
        data['id'] == uid &&
        data['role'] is String &&
        data['isActive'] is bool &&
        data['uid'] == uid) {
      return;
    }

    await docRef.set({
      'id': uid,
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

  Future<void> _ensureUserProfileBestEffort(String uid) async {
    try {
      await _ensureUserProfile(uid);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
    }
  }
}
