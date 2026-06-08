import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoriteProvider>();
    _loadFavoritesIfNeeded(context, auth, favorites);
    final isFavorite = auth.canBuy &&
        favorites.userId == auth.currentUser?.uid &&
        favorites.isFavorite(product.id);
    final isToggling = favorites.isToggling(product.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : 220.0;

        return SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: product.id,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.greyLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 112,
                          width: double.infinity,
                          child: ColoredBox(
                            color: AppTheme.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_outlined,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  height: 16,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppTheme.star,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${product.rating}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _priceText(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: isToggling
                        ? null
                        : () => _toggleFavorite(
                              context,
                              auth,
                              favorites,
                              shouldFavorite: !isFavorite,
                            ),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    iconSize: 17,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    color: isFavorite ? AppTheme.favorite : AppTheme.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _priceText(Product product) {
    return Formatters.currency(product.minPrice);
  }

  void _loadFavoritesIfNeeded(
    BuildContext context,
    AuthProvider auth,
    FavoriteProvider favorites,
  ) {
    final uid = auth.currentUser?.uid;
    if (uid == null || !auth.canBuy) return;
    if (favorites.userId == uid || favorites.isLoading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<FavoriteProvider>().loadFavorites(uid);
      }
    });
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    AuthProvider auth,
    FavoriteProvider favorites, {
    required bool shouldFavorite,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || auth.isGuest) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (!auth.canBuy) {
      _showMessage(context, 'Tài khoản này không dùng để lưu yêu thích');
      return;
    }

    final isNowFavorite = await favorites.setFavorite(
      uid,
      product.id,
      shouldFavorite: shouldFavorite,
    );
    if (!context.mounted) return;

    if (favorites.error != null) {
      _showMessage(context, favorites.error!);
      return;
    }

    if (isNowFavorite) {
      _showMessage(context, 'Đã thêm vào yêu thích');
      return;
    }

    _showMessage(context, 'Đã bỏ yêu thích');
  }

  void _showMessage(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
              ),
      ),
    );
  }
}
