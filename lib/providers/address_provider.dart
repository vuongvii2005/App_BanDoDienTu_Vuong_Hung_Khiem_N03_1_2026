import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  final AddressService _addressService;

  List<AddressModel> _addresses = <AddressModel>[];
  bool _isLoading = false;
  String? _error;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  AddressModel? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault) return address;
    }
    return _addresses.isEmpty ? null : _addresses.first;
  }

  Future<void> loadAddresses(String uid) async {
    _setLoading(true);
    _error = null;

    try {
      _addresses = await _addressService.getAddresses(uid);
    } catch (error) {
      _error = 'Khong tai duoc dia chi';
      _addresses = <AddressModel>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> saveAddress(String uid, AddressModel address) async {
    _setLoading(true);
    _error = null;

    try {
      final savedId = await _addressService.saveAddress(uid, address);
      _addresses = await _addressService.getAddresses(uid);
      return savedId;
    } catch (error) {
      _error = 'Khong luu duoc dia chi';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setDefaultAddress(String uid, String addressId) async {
    _setLoading(true);
    _error = null;

    try {
      await _addressService.setDefaultAddress(uid, addressId);
      _addresses = await _addressService.getAddresses(uid);
    } catch (error) {
      _error = 'Khong cap nhat duoc dia chi mac dinh';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    _setLoading(true);
    _error = null;

    try {
      await _addressService.deleteAddress(uid, addressId);
      _addresses = await _addressService.getAddresses(uid);
    } catch (error) {
      _error = 'Khong xoa duoc dia chi';
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _addresses = <AddressModel>[];
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
