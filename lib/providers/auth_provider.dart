// State dang nhap va thong tin nguoi dung.
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
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String get role => _userModel?.role ?? 'guest';
  bool get isGuest => !isLoggedIn;
  bool get isUser => _userModel?.isUser ?? false;
  bool get isAdmin => _userModel?.isAdmin ?? false;
  bool get canBuy => isUser;
  bool get canManageShop => isAdmin;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _authService.login(email, password);
      _currentUser = credential.user ?? _authService.getCurrentUser();
      await _loadUserModel();
      return true;
    } catch (error) {
      _errorMessage = _authService.errorMessage(error);
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
    _errorMessage = null;

    try {
      _userModel = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _currentUser = _authService.getCurrentUser();
      return true;
    } catch (error) {
      _errorMessage = _authService.errorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.logout();
      _currentUser = null;
      _userModel = null;
    } catch (error) {
      _errorMessage = _authService.errorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _currentUser = _authService.getCurrentUser();
    await _loadUserModel();
    _setLoading(false);
  }

  Future<void> reloadUser() => loadCurrentUser();

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (error) {
      _errorMessage = _authService.errorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _handleAuthState(User? firebaseUser) async {
    _currentUser = firebaseUser;

    if (firebaseUser == null) {
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _loadUserModel();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    final user = _currentUser;
    if (user == null) {
      _userModel = null;
      return;
    }

    try {
      _userModel = await _authService.getUserModel(user.uid);
      _errorMessage = null;
    } catch (error) {
      _userModel = null;
      _errorMessage = _authService.errorMessage(error);
    }
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
