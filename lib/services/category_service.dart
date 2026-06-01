//thao tác collection categories
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  Future<List<CategoryModel>> getCategories() async {
    final snapshot =
        await _categories.where('isActive', isEqualTo: true).get();
    final categories =
        snapshot.docs.map(CategoryModel.fromFirestore).toList();

    categories.sort((first, second) {
      final byOrder = first.sortOrder.compareTo(second.sortOrder);
      if (byOrder != 0) return byOrder;
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });

    return categories;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    if (id.trim().isEmpty) return null;

    final doc = await _categories.doc(id).get();
    if (!doc.exists) return null;

    final category = CategoryModel.fromFirestore(doc);
    return category.isActive ? category : null;
  }
}
