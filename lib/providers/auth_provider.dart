// - đăng nhập
// - đăng ký
// - đăng xuất
// - lấy uid hiện tại
// - kiểm tra đã login chưa

// AuthService
// - xử lý Firebase Auth
// AuthProvider
// - giữ trạng thái đăng nhập cho giao diện
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  // Mock login — thay bằng Firebase sau
  Future<bool> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _user = UserModel(
      id: 'user_001',
      name: 'Vương Hùng Khiêm',
      email: email,
      phone: '0901 234 567',
      avatarUrl: 'https://i.pravatar.cc/100',
      address: '123 Nguyễn Văn Cừ, Phường 1, Quận 5, TP. Hồ Chí Minh',
    );
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    _loading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
