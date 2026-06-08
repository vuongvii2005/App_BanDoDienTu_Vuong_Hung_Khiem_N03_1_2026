import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_footer.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/home/banner_slider.dart';
import '../widgets/home/category_section.dart';
import '../widgets/home/featured_products.dart';
import '../widgets/home/flash_sale_section.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    _loadCartForCurrentUser(auth, cart);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: _currentIndex == 4 && auth.isLoggedIn
              ? const ProfileScreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(auth),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    const BannerSlider(),
                    const SizedBox(height: 20),
                    const CategorySection(),
                    const SizedBox(height: 20),
                    const FeaturedProducts(),
                    const FlashSaleSection(),
                    const AppFooter(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onBottomNavTap(i, auth),
      ),
    );
  }

  Future<void> _onBottomNavTap(int index, AuthProvider auth) async {
    if (index == 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    if (index == 4) {
      if (auth.isLoggedIn) {
        setState(() => _currentIndex = 4);
        return;
      }

      setState(() => _currentIndex = 0);
      await Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final route = _routeForBottomNavIndex(index);
    if (route == null) return;

    setState(() => _currentIndex = index);
    await Navigator.pushNamed(context, route);
    if (!mounted) return;

    setState(() => _currentIndex = 0);
  }

  String? _routeForBottomNavIndex(int index) {
    if (index == 1) return AppRoutes.productList;
    if (index == 2) return AppRoutes.cart;
    if (index == 3) return AppRoutes.orderHistory;
    return null;
  }

  void _loadCartForCurrentUser(AuthProvider auth, CartProvider cart) {
    final uid = auth.currentUser?.uid;
    if (uid == null || !auth.canBuy) {
      if (cart.items.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => cart.clearLocal());
      }
      return;
    }

    if (cart.userId == uid || cart.isLoading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartProvider>().loadCart(uid);
    });
  }

  Widget _buildHeader(AuthProvider auth) {
    final user = auth.userModel;
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'Khách';
    final avatarUrl = user?.avatarUrl ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (!auth.isLoggedIn) {
                Navigator.pushNamed(context, AppRoutes.login);
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.greyLight,
                image: avatarUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person_outline, color: AppTheme.grey)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào,',
                  style: TextStyle(fontSize: 12, color: AppTheme.grey),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              auth.canManageShop
                  ? Icons.admin_panel_settings_outlined
                  : Icons.notifications_outlined,
              size: 26,
            ),
            onPressed: auth.canManageShop
                ? () => Navigator.pushNamed(context, AppRoutes.admin)
                : () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.greyLight),
          ),
          child: const Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.search, color: AppTheme.grey, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tìm sản phẩm, thương hiệu...',
                  style: TextStyle(color: AppTheme.grey, fontSize: 14),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.tune, color: AppTheme.grey, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
