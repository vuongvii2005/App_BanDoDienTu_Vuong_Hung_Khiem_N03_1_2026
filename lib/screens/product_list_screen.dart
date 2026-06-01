import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../utils/formatters.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;

  const ProductListScreen({super.key, this.categoryId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().selectCategory(widget.categoryId);
      context.read<CategoryProvider>().selectCategory(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = context.watch<CategoryProvider>();
    final cart = context.watch<CartProvider>();
    final products = provider.filteredProducts;
    final title = _screenTitle(categories, provider.selectedCategoryId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: provider.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Tìm sản phẩm...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.greyLight),
                  ),
                  child: const Icon(Icons.tune, color: AppTheme.grey),
                ),
              ],
            ),
          ),
          _buildCategoryChips(context, categories, provider),
          const SizedBox(height: 8),
          Expanded(child: _buildProductList(provider, products)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(
    BuildContext context,
    CategoryProvider categories,
    ProductProvider products,
  ) {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'Tất cả',
            isSelected: products.selectedCategoryId == null,
            onTap: () {
              categories.clearSelectedCategory();
              products.selectCategory(null);
            },
          ),
          ...categories.categories.map((category) {
            return _chip(
              label: category.name,
              isSelected: products.selectedCategoryId == category.id,
              onTap: () {
                categories.selectCategory(category.id);
                products.selectCategory(category.id);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.greyLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : AppTheme.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(ProductProvider provider, List<Product> products) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: AppTheme.grey),
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'Không có sản phẩm',
          style: TextStyle(color: AppTheme.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildProductTile(context, products[i]),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    final firstStorage =
        product.storageOptions.isNotEmpty ? product.storageOptions.first : '';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(width: 90, height: 90, color: AppTheme.greyLight),
                errorWidget: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: AppTheme.greyLight,
                  child: const Icon(Icons.image_outlined, color: AppTheme.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (firstStorage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      firstStorage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.star, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currency(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.currentUser == null) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final storage =
        product.storageOptions.isNotEmpty ? product.storageOptions.first : '';
    final color = product.colorOptions.isNotEmpty ? product.colorOptions.first : '';

    await context.read<CartProvider>().addToCart(
          auth.currentUser!.uid,
          product,
          storage,
          color,
        );

    if (!mounted) return;
    final error = context.read<CartProvider>().error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã thêm vào giỏ hàng'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _screenTitle(CategoryProvider categories, String? categoryId) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return 'Tất cả sản phẩm';
    }

    final category = categories.getCategoryById(categoryId);
    return category?.name ?? 'Sản phẩm';
  }
}
