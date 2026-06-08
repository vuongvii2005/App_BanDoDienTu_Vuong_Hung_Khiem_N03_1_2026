//state thông tin người dùng
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  UserModel? _user;
  List<UserModel> _users = <UserModel>[];
  bool _isLoading = false;
  bool _isAdminLoading = false;
  String? _error;
  String? _adminError;

  UserModel? get user => _user;
  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  bool get isAdminLoading => _isAdminLoading;
  String? get error => _error;
  String? get adminError => _adminError;

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

  Future<void> loadUsers() async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      _users = await _userService.getUsers();
    } catch (error) {
      _adminError = 'Không tải được danh sách người dùng';
      _users = <UserModel>[];
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> updateUserRole(String uid, String role) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _userService.updateRole(uid, role);
      _updateCachedUser(
        uid,
        (user) => user.copyWith(role: role, updatedAt: DateTime.now()),
      );
      return true;
    } catch (error) {
      _adminError = 'Không cập nhật được quyền người dùng';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> updateUserActive(String uid, bool isActive) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _userService.updateActive(uid, isActive);
      _updateCachedUser(
        uid,
        (user) => user.copyWith(
          isActive: isActive,
          updatedAt: DateTime.now(),
        ),
      );
      return true;
    } catch (error) {
      _adminError = 'Không cập nhật được trạng thái người dùng';
      return false;
    } finally {
      _setAdminLoading(false);
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

  void _setAdminLoading(bool value) {
    _isAdminLoading = value;
    notifyListeners();
  }

  void _updateCachedUser(
    String uid,
    UserModel Function(UserModel user) update,
  ) {
    final index = _users.indexWhere((user) => user.uid == uid);
    if (index != -1) {
      _users[index] = update(_users[index]);
    }

    if (_user?.uid == uid) {
      _user = update(_user!);
    }
  }
}
