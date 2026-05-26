import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductService? productService})
    : _productService = productService ?? ProductService();

  final ProductService _productService;

  StreamSubscription<List<Product>>? _productsSubscription;

  List<Product> _allProducts = <Product>[];
  List<Product> _products = <Product>[];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  String? _selectedCategoryId;

  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get products => List.unmodifiable(_products);
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchKeyword => _searchKeyword;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get hasProducts => _products.isNotEmpty;

  Future<void> loadProducts() async {
    _startLoading();

    try {
      _allProducts = await _productService.getAllProducts();
      _errorMessage = null;
      _applyFilters(notify: false);
    } catch (error) {
      _setError(error);
    } finally {
      _finishLoading();
    }
  }

  Future<void> listenToProducts() async {
    await _productsSubscription?.cancel();
    _startLoading();

    _productsSubscription = _productService.watchProducts().listen(
      (products) {
        _allProducts = products;
        _errorMessage = null;
        _applyFilters(notify: false);
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _setError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> stopListeningProducts() async {
    await _productsSubscription?.cancel();
    _productsSubscription = null;
  }

  Future<void> selectProductById(String productId) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      _selectedProduct = null;
      notifyListeners();
      return;
    }

    _startLoading();

    try {
      _selectedProduct = await _productService.getProductById(normalizedId);
      _errorMessage = null;
    } catch (error) {
      _setError(error);
    } finally {
      _finishLoading();
    }
  }

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void searchProducts(String keyword) {
    _searchKeyword = keyword.trim();
    _applyFilters();
  }

  void filterByCategory(String? categoryId) {
    final normalizedCategoryId = categoryId?.trim();
    _selectedCategoryId =
        normalizedCategoryId == null || normalizedCategoryId.isEmpty
        ? null
        : normalizedCategoryId;
    _applyFilters();
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedCategoryId = null;
    _applyFilters();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> addProduct(Product product) async {
    _startLoading();

    try {
      final productId = await _productService.addProduct(product);
      _upsertProduct(product.copyWith(id: productId));
      _errorMessage = null;
      _applyFilters(notify: false);
      return productId;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _finishLoading();
    }
  }

  Future<bool> updateProduct(Product product) async {
    _startLoading();

    try {
      await _productService.updateProduct(product);
      _upsertProduct(product);
      if (_selectedProduct?.id == product.id) {
        _selectedProduct = product;
      }
      _errorMessage = null;
      _applyFilters(notify: false);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _finishLoading();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      _errorMessage = 'Product id cannot be empty.';
      notifyListeners();
      return false;
    }

    _startLoading();

    try {
      await _productService.deleteProduct(normalizedId);
      _allProducts.removeWhere((product) => product.id == normalizedId);
      if (_selectedProduct?.id == normalizedId) {
        _selectedProduct = null;
      }
      _errorMessage = null;
      _applyFilters(notify: false);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _finishLoading();
    }
  }

  Future<bool> toggleFavorite(Product product) async {
    final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
    return updateProduct(updatedProduct);
  }

  void _upsertProduct(Product product) {
    final index = _allProducts.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      _allProducts.add(product);
    } else {
      _allProducts[index] = product;
    }
    _sortProducts();
  }

  void _applyFilters({bool notify = true}) {
    Iterable<Product> filteredProducts = _allProducts;

    final categoryId = _selectedCategoryId;
    if (categoryId != null && categoryId.isNotEmpty) {
      filteredProducts = filteredProducts.where(
        (product) => product.categoryId == categoryId,
      );
    }

    final keyword = _searchKeyword.toLowerCase();
    if (keyword.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(keyword) ||
            product.description.toLowerCase().contains(keyword) ||
            (product.brand?.toLowerCase().contains(keyword) ?? false);
      });
    }

    _products = filteredProducts.toList();

    if (notify) {
      notifyListeners();
    }
  }

  void _sortProducts() {
    _allProducts.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(Object error) {
    _errorMessage = error.toString();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
