import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coupon_model.dart';

class CouponService {
  CouponService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coupons =>
      _firestore.collection('coupons');

  Future<List<CouponModel>> getActiveCoupons() async {
    return getCoupons(activeOnly: true);
  }

  Future<List<CouponModel>> getCoupons({bool activeOnly = true}) async {
    final query =
        activeOnly ? _coupons.where('isActive', isEqualTo: true) : _coupons;
    final snapshot = await query.get();
    final coupons = snapshot.docs.map(CouponModel.fromFirestore).toList();
    coupons.sort((first, second) => first.code.compareTo(second.code));
    return coupons;
  }

  Future<CouponModel?> getCouponByCode(String code) async {
    final normalizedCode = CouponModel.normalizeCode(code);
    if (normalizedCode.isEmpty) return null;

    final snapshot = await _coupons
        .where('code', isEqualTo: normalizedCode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return CouponModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> incrementUsedCount(String code) async {
    final normalizedCode = CouponModel.normalizeCode(code);
    if (normalizedCode.isEmpty) return;

    final snapshot = await _coupons
        .where('code', isEqualTo: normalizedCode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;

    await snapshot.docs.first.reference.update({
      'usedCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> saveCoupon(CouponModel coupon) async {
    final normalizedCode = CouponModel.normalizeCode(coupon.code);
    final couponId = coupon.id.trim().isEmpty
        ? normalizedCode
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '')
        : coupon.id.trim();
    final docRef = _coupons.doc(couponId);

    await docRef.set({
      ...coupon.toMap(),
      'id': docRef.id,
      'code': normalizedCode,
      'createdAt': coupon.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  Future<void> setCouponActive(String id, bool isActive) async {
    if (id.trim().isEmpty) return;

    await _coupons.doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
