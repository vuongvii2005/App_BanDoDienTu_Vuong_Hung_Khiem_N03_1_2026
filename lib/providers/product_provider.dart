//state sản phẩm
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/product_variant_model.dart';
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
  final Map<String, List<ProductVariant>> _variantsByProductId =
      <String, List<ProductVariant>>{};
  final Set<String> _loadingVariantProductIds = <String>{};
  String? _variantError;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String? get variantError => _variantError;

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

  List<ProductVariant> getVariants(String productId) {
    return List.unmodifiable(
      _variantsByProductId[productId] ?? <ProductVariant>[],
    );
  }

  bool isLoadingVariants(String productId) {
    return _loadingVariantProductIds.contains(productId);
  }

  Future<List<ProductVariant>> loadVariants(
    String productId, {
    bool force = false,
  }) async {
    if (productId.trim().isEmpty) return <ProductVariant>[];
    if (!force && _variantsByProductId.containsKey(productId)) {
      return getVariants(productId);
    }

    _loadingVariantProductIds.add(productId);
    _variantError = null;
    notifyListeners();

    try {
      final variants = await _productService.getVariantsByProduct(productId);
      _variantsByProductId[productId] = variants;
      return variants;
    } catch (error) {
      _variantError = 'Không tải được biến thể sản phẩm';
      _variantsByProductId[productId] = <ProductVariant>[];
      return <ProductVariant>[];
    } finally {
      _loadingVariantProductIds.remove(productId);
      notifyListeners();
    }
  }

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
