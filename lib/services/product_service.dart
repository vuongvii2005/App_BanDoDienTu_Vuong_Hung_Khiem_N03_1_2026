//thao tác collection products
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../models/product_variant_model.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> _variants(String productId) =>
      _products.doc(productId).collection('variants');

  Future<List<Product>> getAllProducts() async {
    return getProducts(activeOnly: true);
  }

  Future<List<Product>> getProducts({bool activeOnly = true}) async {
    final query =
        activeOnly ? _products.where('isActive', isEqualTo: true) : _products;
    final snapshot = await query.get();
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

  Future<List<ProductVariant>> getVariantsByProduct(String productId) async {
    if (productId.trim().isEmpty) return <ProductVariant>[];

    final snapshot =
        await _variants(productId).where('isActive', isEqualTo: true).get();
    final variants = snapshot.docs
        .map((doc) => ProductVariant.fromFirestore(doc, productId: productId))
        .toList();

    variants.sort((first, second) {
      final byStorage = first.storage.compareTo(second.storage);
      if (byStorage != 0) return byStorage;
      return first.color.compareTo(second.color);
    });

    return variants;
  }

  Future<ProductVariant?> getVariantById(
    String productId,
    String variantId,
  ) async {
    if (productId.trim().isEmpty || variantId.trim().isEmpty) return null;

    final doc = await _variants(productId).doc(variantId).get();
    if (!doc.exists) return null;

    final variant = ProductVariant.fromFirestore(doc, productId: productId);
    return variant.isActive ? variant : null;
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
    final docRef =
        productId.isEmpty ? _products.doc() : _products.doc(productId);

    await docRef.set({
      ...product.toMap(),
      'id': docRef.id,
      'createdAt': product.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _ensureDefaultVariant(docRef.id, product);

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
    await _ensureDefaultVariant(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(id).delete();
  }

  Future<void> setProductActive(String id, bool isActive) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHotDeal(
    String productId,
    int salePrice,
    DateTime? dealStartAt,
    DateTime? dealEndAt,
    int? dealStock,
  ) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(productId).update({
      'isHotDeal': true,
      'salePrice': salePrice,
      'dealStartAt': dealStartAt,
      'dealEndAt': dealEndAt,
      'dealStock': dealStock,
      'dealSold': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> disableHotDeal(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product id cannot be empty.');
    }

    await _products.doc(productId).update({
      'isHotDeal': false,
      'salePrice': FieldValue.delete(),
      'dealStartAt': FieldValue.delete(),
      'dealEndAt': FieldValue.delete(),
      'dealStock': FieldValue.delete(),
      'dealSold': 0,
      'dealQuantity': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _ensureDefaultVariant(String productId, Product product) async {
    final snapshot = await _variants(productId).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    await _variants(productId).doc('default').set({
      'id': 'default',
      'productId': productId,
      'storage': 'Mặc định',
      'color': 'Mặc định',
      'price': product.minPrice,
      'oldPrice': 0,
      'stock': product.totalStock,
      'sku': productId.toUpperCase(),
      'imageUrl': product.imageUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
