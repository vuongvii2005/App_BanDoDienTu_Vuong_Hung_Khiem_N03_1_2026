import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/formatters.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedStorage;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().loadVariants(widget.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.getProductById(widget.productId);
    final variants = provider.getVariants(widget.productId);
    final isLoadingVariants = provider.isLoadingVariants(widget.productId);
    final selectedVariant = _syncAndFindSelectedVariant(variants);
    final cart = context.watch<CartProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppTheme.white,
              height: 280,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: selectedVariant?.imageUrl.isNotEmpty == true
                    ? selectedVariant!.imageUrl
                    : product.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: AppTheme.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.star, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' (${product.reviewCount} đánh giá)',
                        style: const TextStyle(
                          color: AppTheme.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _priceBlock(product, selectedVariant),
                  const SizedBox(height: 8),
                  Text(
                    _stockText(product, selectedVariant),
                    style: const TextStyle(fontSize: 13, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 16),
                  if (isLoadingVariants)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(color: AppTheme.primary),
                    )
                  else if (variants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Sản phẩm chưa có biến thể',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    )
                  else ...[
                    _buildStorageOptions(product, variants),
                    _buildColorOptions(variants),
                  ],
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottom(product, selectedVariant),
    );
  }

  Widget _priceBlock(Product product, ProductVariant? selectedVariant) {
    final price = selectedVariant == null
        ? _priceText(product)
        : Formatters.currency(selectedVariant.price);

    return Row(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        if (selectedVariant != null &&
            selectedVariant.oldPrice > selectedVariant.price) ...[
          const SizedBox(width: 8),
          Text(
            Formatters.currency(selectedVariant.oldPrice),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStorageOptions(Product product, List<ProductVariant> variants) {
    final storages = _unique(variants.map((variant) => variant.storage));
    if (!_shouldShowOptions(storages)) return const SizedBox.shrink();

    return _optionSection(
      title: _variantOptionTitle(product),
      values: storages,
      selectedValue: _selectedStorage,
      onTap: (storage) {
        setState(() {
          _selectedStorage = storage;
          _selectedColor = null;
          _quantity = 1;
        });
      },
    );
  }

  Widget _buildColorOptions(List<ProductVariant> variants) {
    final colors = _unique(
      variants
          .where((variant) => variant.storage == _selectedStorage)
          .map((variant) => variant.color),
    );
    if (!_shouldShowOptions(colors)) return const SizedBox.shrink();

    return _optionSection(
      title: 'Màu sắc',
      values: colors,
      selectedValue: _selectedColor,
      onTap: (color) {
        setState(() {
          _selectedColor = color;
          _quantity = 1;
        });
      },
    );
  }

  Widget _optionSection({
    required String title,
    required List<String> values,
    required String? selectedValue,
    required ValueChanged<String> onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            final isSelected = selectedValue == value;
            return _optionChip(
              label: _optionLabel(value),
              isSelected: isSelected,
              onTap: () => onTap(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _optionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.greyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? AppTheme.primary : AppTheme.black,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottom(Product product, ProductVariant? selectedVariant) {
    final canAdd = selectedVariant != null && selectedVariant.stock > 0;
    final maxQuantity = selectedVariant?.stock ?? 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.greyLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove, size: 18),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _quantity < maxQuantity
                      ? () => setState(() => _quantity++)
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canAdd
                  ? () => _addToCart(product, selectedVariant)
                  : () => _showMessage('Vui lòng chọn biến thể còn hàng'),
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Thêm vào giỏ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(
    Product product,
    ProductVariant selectedVariant,
  ) async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest || auth.currentUser == null) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (!auth.canBuy) {
      _showMessage('Tài khoản này không dùng để mua hàng');
      return;
    }

    await context.read<CartProvider>().addToCart(
          auth.currentUser!.uid,
          product,
          selectedVariant,
          quantity: _quantity,
        );

    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  ProductVariant? _syncAndFindSelectedVariant(List<ProductVariant> variants) {
    if (variants.isEmpty) return null;

    final storages = _unique(variants.map((variant) => variant.storage));
    if (_selectedStorage == null || !storages.contains(_selectedStorage)) {
      _selectedStorage = storages.first;
    }

    final colors = _unique(
      variants
          .where((variant) => variant.storage == _selectedStorage)
          .map((variant) => variant.color),
    );
    if (colors.isEmpty) return null;
    if (_selectedColor == null || !colors.contains(_selectedColor)) {
      _selectedColor = colors.first;
    }

    final selected = variants.where(
      (variant) =>
          variant.storage == _selectedStorage &&
          variant.color == _selectedColor,
    );
    return selected.isEmpty ? null : selected.first;
  }

  List<String> _unique(Iterable<String> values) {
    final result = <String>[];
    for (final value in values) {
      if (!result.contains(value)) result.add(value);
    }
    return result;
  }

  bool _shouldShowOptions(List<String> values) {
    return values.length > 1 ||
        values.any((value) {
          final normalized = value.trim().toLowerCase();
          return normalized.isNotEmpty &&
              normalized != 'mặc định' &&
              normalized != 'mac dinh';
        });
  }

  String _optionLabel(String value) {
    return value.trim().isEmpty ? 'Mặc định' : value;
  }

  String _stockText(Product product, ProductVariant? selectedVariant) {
    if (selectedVariant == null) return 'Tồn kho: ${product.totalStock}';
    return selectedVariant.stock > 0
        ? 'Tồn kho: ${selectedVariant.stock}'
        : 'Hết hàng';
  }

  String _priceText(Product product) {
    return Formatters.currency(product.minPrice);
  }

  String _variantOptionTitle(Product product) {
    if (product.categoryId == 'phone' || product.categoryId == 'tablet') {
      return 'Dung lượng';
    }

    if (product.categoryId == 'laptop') return 'Ổ cứng';
    if (product.categoryId == 'watch') return 'Kích thước';

    switch (product.id) {
      case 'cap-usb-c-to-lightning':
        return 'Chiều dài';
      case 'keychron-k2':
        return 'Loại switch';
      case 'anker-powercore-20000mah':
        return 'Dung lượng pin';
      default:
        return 'Phiên bản';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
