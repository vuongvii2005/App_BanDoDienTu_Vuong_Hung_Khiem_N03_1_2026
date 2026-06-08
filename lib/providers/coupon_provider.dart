import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponProvider extends ChangeNotifier {
  CouponProvider({CouponService? couponService})
      : _couponService = couponService ?? CouponService();

  final CouponService _couponService;

  List<CouponModel> _coupons = <CouponModel>[];
  bool _isLoading = false;
  String? _error;

  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<CouponModel?> applyCoupon(String code, int subtotal) async {
    _setLoading(true);
    _error = null;

    try {
      final coupon = await _couponService.getCouponByCode(code);
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
}
