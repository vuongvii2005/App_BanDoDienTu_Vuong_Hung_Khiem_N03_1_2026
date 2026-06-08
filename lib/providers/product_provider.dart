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
  List<Product> _adminProducts = <Product>[];
  bool _isLoading = false;
  bool _isAdminLoading = false;
  String? _error;
  String? _adminError;
  String? _selectedCategoryId;
  String _searchQuery = '';
  final Map<String, List<ProductVariant>> _variantsByProductId =
      <String, List<ProductVariant>>{};
  final Set<String> _loadingVariantProductIds = <String>{};
  String? _variantError;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get adminProducts => List.unmodifiable(_adminProducts);
  bool get isLoading => _isLoading;
  bool get isAdminLoading => _isAdminLoading;
  String? get error => _error;
  String? get adminError => _adminError;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String? get variantError => _variantError;

  List<Product> get featuredProducts =>
      _products.where((product) => product.isFeatured).toList();

  List<Product> get hotDeals {
    final products =
        _products.where((product) => product.hasActiveDeal).toList();

    products.sort((first, second) {
      final firstEndAt = first.dealEndAt;
      final secondEndAt = second.dealEndAt;
      if (firstEndAt == null && secondEndAt == null) {
        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      }
      if (firstEndAt == null) return 1;
      if (secondEndAt == null) return -1;
      return firstEndAt.compareTo(secondEndAt);
    });

    return products;
  }

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

  Future<void> loadAdminProducts() async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      _adminProducts = await _productService.getProducts(activeOnly: false);
    } catch (error) {
      _adminError = 'Không tải được danh sách sản phẩm quản trị';
      _adminProducts = <Product>[];
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> saveProduct(Product product) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      final id = product.id.trim().isEmpty
          ? await _productService.addProduct(product)
          : product.id;

      if (product.id.trim().isNotEmpty) {
        await _productService.updateProduct(product);
      }

      final savedProduct = product.copyWith(id: id);
      _upsertProduct(_adminProducts, savedProduct);
      if (savedProduct.isActive) {
        _upsertProduct(_products, savedProduct);
      } else {
        _products.removeWhere((item) => item.id == savedProduct.id);
      }
      _sortProducts(_adminProducts);
      _sortProducts(_products);
      return true;
    } catch (error) {
      _adminError = product.id.trim().isEmpty
          ? 'Không thêm được sản phẩm'
          : 'Không cập nhật được sản phẩm';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> setProductActive(String id, bool isActive) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _productService.setProductActive(id, isActive);
      _setCachedProductActive(_adminProducts, id, isActive);
      _setCachedProductActive(_products, id, isActive);
      if (!isActive) {
        _products.removeWhere((product) => product.id == id);
      } else {
        await loadProducts();
      }
      return true;
    } catch (error) {
      _adminError =
          isActive ? 'Không khôi phục được sản phẩm' : 'Không ẩn được sản phẩm';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> updateHotDeal(
    String productId,
    int salePrice,
    DateTime? dealStartAt,
    DateTime? dealEndAt,
    int? dealStock,
  ) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _productService.updateHotDeal(
        productId,
        salePrice,
        dealStartAt,
        dealEndAt,
        dealStock,
      );
      await Future.wait([
        loadProducts(),
        loadAdminProducts(),
      ]);
      return true;
    } catch (error) {
      _adminError = 'Không tạo được deal';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

  Future<bool> disableHotDeal(String productId) async {
    _setAdminLoading(true);
    _adminError = null;

    try {
      await _productService.disableHotDeal(productId);
      await Future.wait([
        loadProducts(),
        loadAdminProducts(),
      ]);
      return true;
    } catch (error) {
      _adminError = 'Không tắt được deal';
      return false;
    } finally {
      _setAdminLoading(false);
    }
  }

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

  void _setAdminLoading(bool value) {
    _isAdminLoading = value;
    notifyListeners();
  }

  void _upsertProduct(List<Product> products, Product product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      products.add(product);
      return;
    }

    products[index] = product;
  }

  void _setCachedProductActive(
    List<Product> products,
    String id,
    bool isActive,
  ) {
    final index = products.indexWhere((product) => product.id == id);
    if (index == -1) return;

    products[index] = products[index].copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  void _sortProducts(List<Product> products) {
    products.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
  }
}
