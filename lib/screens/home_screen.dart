import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
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
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cart.itemCount),
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
          if (i == 1) Navigator.pushNamed(context, AppRoutes.productList);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.cart);
          if (i == 3) Navigator.pushNamed(context, AppRoutes.orderHistory);
        },
      ),
    );
  }

  Widget _buildHeader(int cartCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.greyLight,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/100'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Greeting
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(fontSize: 12, color: AppTheme.grey),
              ),
              Row(
                children: [
                  Text(
                    'Hi ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Notification icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search, color: AppTheme.grey, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tìm sản phẩm, thương hiệu...',
                  style: TextStyle(color: AppTheme.grey, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: AppTheme.grey, size: 20),
                onPressed: () {},
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
      children: ['02', '18', '45'].asMap().entries.map((e) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (e.key < 2)
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
