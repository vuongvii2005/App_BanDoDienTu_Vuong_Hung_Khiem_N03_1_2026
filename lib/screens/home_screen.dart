import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/home/banner_slider.dart';
import '../widgets/home/category_section.dart';
import '../widgets/home/featured_products.dart';

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
              ? _buildAccountTab(auth)
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
                    const SizedBox(height: 20),
                    _buildFlashSale(),
                    const SizedBox(height: 80),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) {
            Navigator.pushNamed(context, AppRoutes.productList).then((_) {
              setState(() => _currentIndex = 0);
            });
          }
          if (i == 2) {
            Navigator.pushNamed(context, AppRoutes.cart).then((_) {
              setState(() => _currentIndex = 0);
            });
          }

          if (i == 3) {
            Navigator.pushNamed(context, AppRoutes.orderHistory).then((_) {
              setState(() => _currentIndex = 0);
            });
          }

          if (i == 4) {
            if (!auth.isLoggedIn) {
              Navigator.pushNamed(context, AppRoutes.login);
            }
          }
        },
      ),
    );
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

  Widget _buildAccountTab(AuthProvider auth) {
    final user = auth.userModel;
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'Khách';
    final email = user?.email ?? auth.currentUser?.email ?? '';
    final role = auth.canManageShop ? 'Admin' : 'Người dùng';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Cá nhân',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.greyLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppTheme.greyLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (auth.canManageShop)
            _accountButton(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Quản trị shop',
              onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
            ),
          _accountButton(
            icon: Icons.receipt_long_outlined,
            label: 'Đơn hàng của tôi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
          ),
          _accountButton(
            icon: Icons.logout,
            label: 'Đăng xuất',
            color: AppTheme.error,
            onTap: _logout,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _accountButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.greyLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    context.read<CartProvider>().clearLocal();
    setState(() => _currentIndex = 0);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
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

  Widget _buildFlashSale() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text(
              'Deal hot hôm nay',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildCountdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Row(
      children: ['02', '18', '45'].asMap().entries.map((entry) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (entry.key < 2)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
