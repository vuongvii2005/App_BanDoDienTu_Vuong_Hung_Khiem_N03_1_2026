import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collectionName = 'products';

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(_collectionName);

  Stream<List<Product>> watchProducts() {
    return _products.snapshots().map(_productsFromSnapshot);
  }

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return _products
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(_productsFromSnapshot);
  }

  Stream<Product?> watchProductById(String productId) {
    if (productId.trim().isEmpty) {
      return Stream<Product?>.value(null);
    }

    return _products.doc(productId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      return _productFromDoc(doc);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final snapshot = await _products.get();
    return _productsFromSnapshot(snapshot);
  }

  Future<Product?> getProductById(String productId) async {
    if (productId.trim().isEmpty) {
      return null;
    }

    final doc = await _products.doc(productId).get();
    if (!doc.exists) {
      return null;
    }

    return _productFromDoc(doc);
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      return <Product>[];
    }

    final snapshot =
        await _products.where('categoryId', isEqualTo: categoryId).get();
    return _productsFromSnapshot(snapshot);
  }

  Future<List<Product>> searchProducts(
    String keyword, {
    String? categoryId,
  }) async {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final products = categoryId == null || categoryId.trim().isEmpty
        ? await getAllProducts()
        : await getProductsByCategory(categoryId);

    if (normalizedKeyword.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(normalizedKeyword) ||
          product.description.toLowerCase().contains(normalizedKeyword) ||
          (product.brand?.toLowerCase().contains(normalizedKeyword) ?? false);
    }).toList();
  }

  Future<String> addProduct(Product product) async {
    final productId = product.id.trim();
    final data = product.toJson();

    if (productId.isEmpty) {
      final docRef = _products.doc();
      await docRef.set({
        ...data,
        'id': docRef.id,
      });
      return docRef.id;
    }

    await _products.doc(productId).set({
      ...data,
      'id': productId,
    });
    return productId;
  }

  Future<void> updateProduct(Product product) async {
    final productId = product.id.trim();
    if (productId.isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(productId).update({
      ...product.toJson(),
      'id': productId,
    });
  }

  Future<void> updateProductFields(
    String productId,
    Map<String, dynamic> data,
  ) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(productId).delete();
  }

  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Product.fromJson({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }

  List<Product> _productsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final products = snapshot.docs.map(_productFromDoc).toList();
    products.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    return products;
  }
}
