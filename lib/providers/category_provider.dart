//state danh mục
import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService() {
    loadCategories();
  }

  final CategoryService _categoryService;

  List<CategoryModel> _categories = <CategoryModel>[];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategoryId;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      _categories = await _categoryService.getCategories();
    } catch (error) {
      _error = 'Không tải được danh mục';
      _categories = <CategoryModel>[];
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId =
        categoryId == null || categoryId.trim().isEmpty ? null : categoryId;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategoryId = null;
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
