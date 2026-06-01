//thao tác collection products
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Future<List<Product>> getAllProducts() async {
    final snapshot = await _products.where('isActive', isEqualTo: true).get();
    return _productsFromSnapshot(snapshot);
  }

  Future<List<Product>> getFeaturedProducts() async {
    final products = await getAllProducts();
    return products.where((product) => product.isFeatured).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    if (categoryId.trim().isEmpty) return <Product>[];

    final products = await getAllProducts();
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    if (id.trim().isEmpty) return null;

    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;

    final product = Product.fromFirestore(doc);
    return product.isActive ? product : null;
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final query = keyword.trim().toLowerCase();
    final products = await getAllProducts();

    if (query.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<String> addProduct(Product product) async {
    final productId = product.id.trim();
    final docRef = productId.isEmpty ? _products.doc() : _products.doc(productId);

    await docRef.set({
      ...product.toMap(),
      'id': docRef.id,
      'createdAt': product.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateProduct(Product product) async {
    if (product.id.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(product.id).update({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(id).delete();
  }

  List<Product> _productsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final products = snapshot.docs.map(Product.fromFirestore).toList();
    products.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    return products;
  }
}
