//state thông tin người dùng
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String uid) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _userService.getUser(uid);
    } catch (error) {
      _error = 'Không tải được thông tin người dùng';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(UserModel user) async {
    _setLoading(true);
    _error = null;

    try {
      await _userService.updateUser(user);
      _user = user;
    } catch (error) {
      _error = 'Không cập nhật được thông tin người dùng';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAddress(String uid, String address) async {
    await _userService.updateAddress(uid, address);
    if (_user != null) {
      _user = _user!.copyWith(address: address, updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _userService.updateAvatar(uid, avatarUrl);
    if (_user != null) {
      _user = _user!.copyWith(avatarUrl: avatarUrl, updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
