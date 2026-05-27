import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/mock_data.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _all = MockData.products;
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;

  List<Product> get featured => _all.where((p) => p.isFeatured).toList();

  List<Product> get filtered {
    return _all.where((p) {
      final matchCat =
          _selectedCategory == 'Tất cả' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchCat && matchSearch;
    }).toList();
  }

  Product? getById(String id) =>
      _all.firstWhere((p) => p.id == id, orElse: () => _all.first);

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
