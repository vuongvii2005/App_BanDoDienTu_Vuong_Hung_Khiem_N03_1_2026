import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/cart_provider.dart';

class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animControllers;

  @override
  void initState() {
    super.initState();
    _animControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void didUpdateWidget(AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animControllers[widget.currentIndex].forward();
      _animControllers[oldWidget.currentIndex].reverse();
    }
  }

  @override
  void dispose() {
    for (var controller in _animControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _buildItem(
                context,
                0,
                Icons.home_outlined,
                Icons.home,
                'Trang chủ',
                _animControllers[0],
              ),
              _buildItem(
                context,
                1,
                Icons.grid_view_outlined,
                Icons.grid_view,
                'Danh mục',
                _animControllers[1],
              ),
              _buildCartItem(context, cartCount, _animControllers[2]),
              _buildItem(
                context,
                3,
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Đơn hàng',
                _animControllers[3],
              ),
              _buildItem(
                context,
                4,
                Icons.person_outline,
                Icons.person,
                'Cá nhân',
                _animControllers[4],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    AnimationController controller,
  ) {
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.3).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppTheme.primary : AppTheme.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppTheme.primary : AppTheme.grey,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    int count,
    AnimationController controller,
  ) {
    final isActive = widget.currentIndex == 2;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(2),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.3).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive
                        ? Icons.shopping_cart
                        : Icons.shopping_cart_outlined,
                    color: isActive ? AppTheme.primary : AppTheme.grey,
                    size: 24,
                  ),
                  if (count > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: controller,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
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
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppTheme.primary : AppTheme.grey,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: const Text('Giỏ hàng'),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
