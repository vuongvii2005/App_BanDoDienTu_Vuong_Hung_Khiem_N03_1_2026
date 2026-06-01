//state sản phẩm 
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService() {
    loadProducts();
  }

  final ProductService _productService;

  List<Product> _products = <Product>[];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategoryId;
  String _searchQuery = '';

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<Product> get featuredProducts =>
      _products.where((product) => product.isFeatured).toList();

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final matchCategory = _selectedCategoryId == null ||
          _selectedCategoryId!.trim().isEmpty ||
          product.categoryId == _selectedCategoryId;

      final matchSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      return matchCategory && matchSearch;
    }).toList();
  }

  // Old UI aliases kept during the migration.
  List<Product> get featured => featuredProducts;
  List<Product> get filtered => filteredProducts;
  String get selectedCategory => _selectedCategoryId ?? '';

  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      _products = await _productService.getAllProducts();
    } catch (error) {
      _error = 'Không tải được sản phẩm';
      _products = <Product>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProducts() => loadProducts();

  void selectCategory(String? categoryId) {
    _selectedCategoryId = _isAllCategory(categoryId) ? null : categoryId;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    selectCategory(categoryId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSearch(String query) {
    setSearchQuery(query);
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Product? getProductById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Product? getById(String id) => getProductById(id);

  bool _isAllCategory(String? categoryId) {
    final value = categoryId?.trim().toLowerCase() ?? '';
    return value.isEmpty || value == 'all' || value == 'tat ca';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
