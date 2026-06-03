//state tìm kiếm
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  final List<String> _history = <String>[];

  String get query => _query;
  List<String> get history => List.unmodifiable(_history);

  List<Product> resultsFrom(List<Product> products) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return <Product>[];

    return products.where((product) {
      return product.name.toLowerCase().contains(normalized) ||
          product.brand.toLowerCase().contains(normalized) ||
          product.description.toLowerCase().contains(normalized);
    }).toList();
  }

  void search(String query) {
    _query = query;
    final trimmed = query.trim();
    if (trimmed.isNotEmpty && !_history.contains(trimmed)) {
      _history.insert(0, trimmed);
      if (_history.length > 10) _history.removeLast();
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void clear() {
    _query = '';
    notifyListeners();
  }
}
