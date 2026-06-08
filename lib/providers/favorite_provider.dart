import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/favorite_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  final FavoriteService _favoriteService;

  List<FavoriteModel> _favorites = <FavoriteModel>[];
  final Set<String> _favoriteProductIds = <String>{};
  final Set<String> _togglingProductIds = <String>{};
  bool _isLoading = false;
  bool _hasLoaded = false;
  int _mutationVersion = 0;
  String? _error;
  String? _userId;

  List<FavoriteModel> get favorites => List.unmodifiable(_favorites);
  Set<String> get favoriteProductIds => Set.unmodifiable(_favoriteProductIds);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  bool isToggling(String productId) {
    return _togglingProductIds.contains(productId);
  }

  Future<void> loadFavorites(String uid, {bool force = false}) async {
    if (uid.trim().isEmpty) {
      clear();
      return;
    }

    if (!force && _userId == uid && _hasLoaded) return;
    if (_isLoading && _userId == uid) return;

    if (_userId != uid) {
      _favorites = <FavoriteModel>[];
      _favoriteProductIds.clear();
      _hasLoaded = false;
    }

    _userId = uid;
    _setLoading(true);
    _error = null;
    final startedMutationVersion = _mutationVersion;

    try {
      final loadedFavorites = await _favoriteService.getFavorites(uid);
      if (startedMutationVersion != _mutationVersion) {
        _hasLoaded = true;
        return;
      }

      _favorites = loadedFavorites;
      _favoriteProductIds
        ..clear()
        ..addAll(_favorites.map((favorite) => favorite.productId));
      _hasLoaded = true;
    } catch (error) {
      _error = 'Khong tai duoc san pham yeu thich';
      _favorites = <FavoriteModel>[];
      _favoriteProductIds.clear();
      _hasLoaded = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFavorite(String uid, String productId) async {
    return setFavorite(
      uid,
      productId,
      shouldFavorite: !isFavorite(productId),
    );
  }

  Future<bool> setFavorite(
    String uid,
    String productId, {
    required bool shouldFavorite,
  }) async {
    if (uid.trim().isEmpty || productId.trim().isEmpty) return false;
    if (_togglingProductIds.contains(productId)) {
      return isFavorite(productId);
    }

    if (_userId != uid) {
      _favorites = <FavoriteModel>[];
      _favoriteProductIds.clear();
      _userId = uid;
      _hasLoaded = true;
    }

    final wasFavorite = isFavorite(productId);
    if (wasFavorite == shouldFavorite) return wasFavorite;

    _mutationVersion++;
    _togglingProductIds.add(productId);
    _error = null;
    _setLocalFavorite(productId, shouldFavorite);
    notifyListeners();

    try {
      if (shouldFavorite) {
        await _favoriteService.addFavorite(uid, productId);
      } else {
        await _favoriteService.removeFavorite(uid, productId);
      }
      _hasLoaded = true;
      _setLocalFavorite(productId, shouldFavorite);
      return shouldFavorite;
    } catch (error) {
      _error = _favoriteErrorMessage(error);
      _setLocalFavorite(productId, wasFavorite);
      return wasFavorite;
    } finally {
      _togglingProductIds.remove(productId);
      notifyListeners();
    }
  }

  void clear() {
    _favorites = <FavoriteModel>[];
    _favoriteProductIds.clear();
    _togglingProductIds.clear();
    _error = null;
    _userId = null;
    _isLoading = false;
    _hasLoaded = false;
    notifyListeners();
  }

  void _setLocalFavorite(String productId, bool isFavorite) {
    if (isFavorite) {
      _favoriteProductIds.add(productId);
      if (!_favorites.any((favorite) => favorite.productId == productId)) {
        _favorites.insert(
          0,
          FavoriteModel(
            id: productId,
            productId: productId,
            createdAt: DateTime.now(),
          ),
        );
      }
      return;
    }

    _favoriteProductIds.remove(productId);
    _favorites = _favorites
        .where((favorite) => favorite.productId != productId)
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _favoriteErrorMessage(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Tai khoan chua duoc cap quyen luu yeu thich';
      }
      if (error.code == 'unavailable' ||
          error.code == 'network-request-failed') {
        return 'Khong ket noi duoc Firebase';
      }
    }

    return 'Khong cap nhat duoc san pham yeu thich';
  }
}
