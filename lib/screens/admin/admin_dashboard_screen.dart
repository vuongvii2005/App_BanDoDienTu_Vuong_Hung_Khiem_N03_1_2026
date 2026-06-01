import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (!auth.canManageShop) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Quản trị shop')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 72,
                  color: AppTheme.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn không có quyền quản lý shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.home,
                  ),
                  child: const Text('Về trang chủ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản trị shop'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            icon: Icons.verified_user_outlined,
            title: 'Admin',
            subtitle: auth.userModel?.email ?? auth.currentUser?.email ?? '',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.inventory_2_outlined,
            title: 'Sản phẩm',
            subtitle: '${products.products.length} sản phẩm đang tải trong app',
            onTap: () => Navigator.pushNamed(context, AppRoutes.productList),
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng',
            subtitle: 'Quản lý đơn hàng bằng màn admin ở bước tiếp theo',
          ),
          const SizedBox(height: 12),
          _card(
            icon: Icons.people_alt_outlined,
            title: 'Người dùng',
            subtitle: 'Role được đọc từ Firestore users/{uid}',
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.greyLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.grey),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppTheme.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }
}
