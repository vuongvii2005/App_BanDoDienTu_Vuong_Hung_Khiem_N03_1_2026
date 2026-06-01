//state đăng nhập, quản lý thông tin người dùng
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authSubscription = _authService.authStateChanges.listen(_handleAuthState);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.login(email, password);
      return true;
    } catch (error) {
      _error = _authService.errorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    String fullName,
    String email,
    String password, {
    String phone = '',
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _userModel = await _authService.register(
        email,
        password,
        fullName,
        phone,
      );
      _currentUser = _authService.currentUser;
      notifyListeners();
      return true;
    } catch (error) {
      _error = _authService.errorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.logout();
      _currentUser = null;
      _userModel = null;
    } catch (error) {
      _error = _authService.errorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadUser() async {
    final user = _authService.currentUser;
    await _handleAuthState(user);
  }

  Future<void> _handleAuthState(User? firebaseUser) async {
    _currentUser = firebaseUser;

    if (firebaseUser == null) {
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _userModel = await _authService.getUserModel(firebaseUser.uid);
      _error = null;
    } catch (error) {
      _error = _authService.errorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
