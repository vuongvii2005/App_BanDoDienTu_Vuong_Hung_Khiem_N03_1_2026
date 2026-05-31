import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/mock_data.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<String> _history = [];

  String get query => _query;
  List<String> get history => _history;

  List<Product> get results {
    if (_query.trim().isEmpty) return [];
    return MockData.products
        .where((p) =>
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.category.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void search(String q) {
    _query = q;
    if (q.trim().isNotEmpty && !_history.contains(q)) {
      _history.insert(0, q);
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
