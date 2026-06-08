import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? _loadedUserId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoriteProvider>();
    final products = context.watch<ProductProvider>();
    _loadFavoritesForCurrentUser(auth, favorites);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
      ),
      body: _buildBody(auth, favorites, products),
    );
  }

  Widget _buildBody(
    AuthProvider auth,
    FavoriteProvider favorites,
    ProductProvider products,
  ) {
    final uid = auth.currentUser?.uid;
    if (uid == null || auth.isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 54,
                color: AppTheme.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Đăng nhập để xem sản phẩm yêu thích',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    if (!auth.canBuy) {
      return const Center(
        child: Text(
          'Tài khoản này không dùng để lưu yêu thích',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grey),
        ),
      );
    }

    if (favorites.isLoading || products.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    final favoriteProducts = _favoriteProducts(favorites, products);
    if (favoriteProducts.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => _refresh(uid),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.favorite_border,
              size: 54,
              color: AppTheme.grey,
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Chưa có sản phẩm yêu thích',
                style: TextStyle(color: AppTheme.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => _refresh(uid),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        itemBuilder: (context, index) {
          return ProductCard(product: favoriteProducts[index]);
        },
      ),
    );
  }

  List<Product> _favoriteProducts(
    FavoriteProvider favorites,
    ProductProvider products,
  ) {
    return favorites.favorites
        .map((favorite) => products.getProductById(favorite.productId))
        .whereType<Product>()
        .toList();
  }

  Future<void> _refresh(String uid) async {
    await Future.wait([
      context.read<FavoriteProvider>().loadFavorites(uid, force: true),
      context.read<ProductProvider>().refreshProducts(),
    ]);
  }

  void _loadFavoritesForCurrentUser(
    AuthProvider auth,
    FavoriteProvider favorites,
  ) {
    final uid = auth.currentUser?.uid;
    if (uid == null || !auth.canBuy) {
      _loadedUserId = null;
      return;
    }

    if (_loadedUserId == uid || favorites.isLoading) return;

    _loadedUserId = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoriteProvider>().loadFavorites(uid);
      }
    });
  }
}
