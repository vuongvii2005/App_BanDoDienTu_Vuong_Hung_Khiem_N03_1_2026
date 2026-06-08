import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponProvider extends ChangeNotifier {
  CouponProvider({CouponService? couponService})
      : _couponService = couponService ?? CouponService();

  final CouponService _couponService;

  List<CouponModel> _coupons = <CouponModel>[];
  List<CouponModel> _adminCoupons = <CouponModel>[];
  bool _isLoading = false;
  bool _isAdminLoading = false;
  String? _error;
  String? _adminError;

  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  List<CouponModel> get adminCoupons => List.unmodifiable(_adminCoupons);
  bool get isLoading => _isLoading;
  bool get isAdminLoading => _isAdminLoading;
  String? get error => _error;
  String? get adminError => _adminError;

  List<CouponModel> availableCouponsFor(int subtotal) {
    final available = _coupons
        .where(
          (coupon) =>
              coupon.isAvailableFor(subtotal) &&
              coupon.discountFor(subtotal) > 0,
        )
        .toList();

    available.sort((first, second) {
      final discountCompare =
          second.discountFor(subtotal).compareTo(first.discountFor(subtotal));
      if (discountCompare != 0) return discountCompare;
      return first.code.compareTo(second.code);
    });
    return available;
  }

  CouponModel? bestCouponFor(int subtotal) {
    final available = availableCouponsFor(subtotal);
    return available.isEmpty ? null : available.first;
  }

  Future<void> loadCoupons() async {
    _setLoading(true);
    _error = null;

    try {
      _coupons = await _couponService.getActiveCoupons();
    } catch (error) {
      _error = 'Khong tai duoc ma giam gia';
      _coupons = <CouponModel>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAdminCoupons() async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      _adminCoupons = await _couponService.getCoupons(activeOnly: false);
    } catch (error) {
      _adminError = 'Không tải được danh sách mã giảm giá';
      _adminCoupons = <CouponModel>[];
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> saveCoupon(CouponModel coupon) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      final id = await _couponService.saveCoupon(coupon);
      final savedCoupon = CouponModel(
        id: id,
        code: CouponModel.normalizeCode(coupon.code),
        type: coupon.type,
        value: coupon.value,
        minOrder: coupon.minOrder,
        maxDiscount: coupon.maxDiscount,
        usageLimit: coupon.usageLimit,
        usedCount: coupon.usedCount,
        startAt: coupon.startAt,
        endAt: coupon.endAt,
        isActive: coupon.isActive,
        createdAt: coupon.createdAt,
        updatedAt: DateTime.now(),
      );
      _upsertCoupon(_adminCoupons, savedCoupon);
      if (savedCoupon.isActive) {
        _upsertCoupon(_coupons, savedCoupon);
      } else {
        _coupons.removeWhere((item) => item.id == savedCoupon.id);
      }
      _sortCoupons(_adminCoupons);
      _sortCoupons(_coupons);
      return true;
    } catch (error) {
      _adminError = 'Không lưu được mã giảm giá';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> setCouponActive(String id, bool isActive) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _couponService.setCouponActive(id, isActive);
      _setCachedCouponActive(_adminCoupons, id, isActive);
      _setCachedCouponActive(_coupons, id, isActive);
      if (!isActive) {
        _coupons.removeWhere((coupon) => coupon.id == id);
      } else {
        await loadCoupons();
      }
      return true;
    } catch (error) {
      _adminError = 'Không cập nhật được trạng thái mã giảm giá';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<CouponModel?> applyCoupon(String code, int subtotal) async {
    _setLoading(true);
    _error = null;

    final normalizedCode = CouponModel.normalizeCode(code);
    if (normalizedCode.isEmpty) {
      _error = 'Vui long nhap ma giam gia';
      _setLoading(false);
      return null;
    }

    try {
      final coupon = await _couponService.getCouponByCode(normalizedCode);
      if (coupon == null) {
        _error = 'Ma giam gia khong ton tai';
        return null;
      }

      if (!coupon.isActive) {
        _error = 'Ma giam gia khong con hoat dong';
        return null;
      }

      if (coupon.reachedUsageLimit) {
        _error = 'Ma giam gia da het luot su dung';
        return null;
      }

      if (subtotal < coupon.minOrder) {
        _error = 'Don hang chua dat gia tri toi thieu';
        return null;
      }

      if (!coupon.isAvailableFor(subtotal)) {
        _error = 'Ma giam gia khong kha dung';
        return null;
      }

      return coupon;
    } catch (error) {
      _error = 'Khong ap dung duoc ma giam gia';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAdminLoading(bool value) {
    _isAdminLoading = value;
    notifyListeners();
  }

  void _upsertCoupon(List<CouponModel> coupons, CouponModel coupon) {
    final index = coupons.indexWhere((item) => item.id == coupon.id);
    if (index == -1) {
      coupons.add(coupon);
      return;
    }

    coupons[index] = coupon;
  }

  void _setCachedCouponActive(
    List<CouponModel> coupons,
    String id,
    bool isActive,
  ) {
    final index = coupons.indexWhere((coupon) => coupon.id == id);
    if (index == -1) return;

    final coupon = coupons[index];
    coupons[index] = CouponModel(
      id: coupon.id,
      code: coupon.code,
      type: coupon.type,
      value: coupon.value,
      minOrder: coupon.minOrder,
      maxDiscount: coupon.maxDiscount,
      usageLimit: coupon.usageLimit,
      usedCount: coupon.usedCount,
      startAt: coupon.startAt,
      endAt: coupon.endAt,
      isActive: isActive,
      createdAt: coupon.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void _sortCoupons(List<CouponModel> coupons) {
    coupons.sort((first, second) => first.code.compareTo(second.code));
  }
}
