import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _loadedOrdersUserId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    _loadOrdersForCurrentUser(auth, orderProvider);

    final user = auth.userModel;
    final name = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Khách';
    final email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : (auth.currentUser?.email ?? '');
    final avatarUrl = user?.avatarUrl.trim() ?? '';
    final rewardPoints = _rewardPoints(orderProvider);
    final voucherCount = _voucherCount(rewardPoints, cart.itemCount);
    final pendingCount = _orderCount(
      orderProvider,
      {OrderStatus.pending, OrderStatus.confirmed},
    );
    final shippingCount = _orderCount(orderProvider, {OrderStatus.shipping});
    final completedCount = _orderCount(orderProvider, {OrderStatus.completed});
    final cancelledCount = _orderCount(orderProvider, {OrderStatus.cancelled});
    final menuItems = _buildMenuItems(auth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(pendingCount + shippingCount),
          const SizedBox(height: 14),
          _buildProfileCard(
            name: name,
            email: email,
            avatarUrl: avatarUrl,
          ),
          const SizedBox(height: 12),
          _buildMemberCard(
            points: rewardPoints,
            vouchers: voucherCount,
            tier: _membershipTier(auth, rewardPoints),
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(
            title: 'Đơn hàng của tôi',
            actionLabel: 'Xem tất cả',
            onActionTap: () => Navigator.pushNamed(
              context,
              AppRoutes.orderHistory,
            ),
          ),
          const SizedBox(height: 10),
          _buildOrderStatusCard(
            statuses: [
              _OrderShortcut(
                icon: Icons.fact_check_outlined,
                label: 'Chờ xác nhận',
                count: pendingCount,
              ),
              _OrderShortcut(
                icon: Icons.local_shipping_outlined,
                label: 'Đang giao',
                count: shippingCount,
              ),
              _OrderShortcut(
                icon: Icons.inventory_2_outlined,
                label: 'Hoàn thành',
                count: completedCount,
              ),
              _OrderShortcut(
                icon: Icons.disabled_by_default_outlined,
                label: 'Đã hủy',
                count: cancelledCount,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildSectionHeader(title: 'Tiện ích'),
          const SizedBox(height: 10),
          _buildUtilityList(menuItems),
          const SizedBox(height: 22),
          _buildLogoutButton(),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  List<_ProfileMenuItem> _buildMenuItems(AuthProvider auth) {
    final items = <_ProfileMenuItem>[
      _ProfileMenuItem(
        icon: Icons.person_outline,
        label: 'Thông tin cá nhân',
        onTap: () => Navigator.pushNamed(context, AppRoutes.profileInfo),
      ),
      _ProfileMenuItem(
        icon: Icons.location_on_outlined,
        label: 'Địa chỉ giao hàng',
        onTap: () => _showComingSoon('Địa chỉ giao hàng'),
      ),
      _ProfileMenuItem(
        icon: Icons.credit_card_outlined,
        label: 'Phương thức thanh toán',
        onTap: () => _showComingSoon('Phương thức thanh toán'),
      ),
      _ProfileMenuItem(
        icon: Icons.confirmation_number_outlined,
        label: 'Mã giảm giá',
        onTap: () => _showComingSoon('Mã giảm giá'),
      ),
      _ProfileMenuItem(
        icon: Icons.favorite_border,
        label: 'Sản phẩm yêu thích',
        onTap: () => _showComingSoon('Sản phẩm yêu thích'),
      ),
      _ProfileMenuItem(
        icon: Icons.support_agent_outlined,
        label: 'Hỗ trợ khách hàng',
        onTap: () => _showComingSoon('Hỗ trợ khách hàng'),
      ),
      _ProfileMenuItem(
        icon: Icons.settings_outlined,
        label: 'Cài đặt',
        onTap: () => _showComingSoon('Cài đặt'),
      ),
    ];

    if (auth.canManageShop) {
      items.insert(
        0,
        _ProfileMenuItem(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Quản trị shop',
          onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
        ),
      );
    }

    return items;
  }

  void _loadOrdersForCurrentUser(AuthProvider auth, OrderProvider orders) {
    final uid = auth.currentUser?.uid;
    if (uid == null || !auth.canBuy) {
      _loadedOrdersUserId = null;
      return;
    }

    if (_loadedOrdersUserId == uid || orders.isLoading) return;

    _loadedOrdersUserId = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderProvider>().loadOrders(uid);
    });
  }

  Widget _buildProfileHeader(int notificationCount) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Cá nhân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildNotificationButton(notificationCount),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(int count) {
    return IconButton(
      onPressed: () => _showComingSoon('Thông báo'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: AppTheme.black),
          if (count > 0)
            Positioned(
              right: -7,
              top: -7,
              child: _buildBadge(count),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
    required String avatarUrl,
  }) {
    return _profileSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _buildAvatar(avatarUrl),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.black,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
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
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showComingSoon('Chỉnh sửa hồ sơ'),
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('Chỉnh sửa'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? _avatarPlaceholder()
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarPlaceholder(),
              ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppTheme.primary.withValues(alpha: 0.12),
      child: const Icon(
        Icons.person,
        color: AppTheme.primary,
        size: 34,
      ),
    );
  }

  Widget _buildMemberCard({
    required int points,
    required int vouchers,
    required String tier,
  }) {
    return GestureDetector(
      onTap: () => _showComingSoon('Thành viên Tech Store'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7EF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22)),
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.10),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Thành viên Tech Store',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                    ),
                  ),
                ),
                _buildTierBadge(tier),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.grey,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMemberMetric(
                    label: 'Điểm thưởng',
                    value: '${_formatNumber(points)} điểm',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppTheme.primary.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _buildMemberMetric(
                    label: 'Voucher của tôi',
                    value: '$vouchers',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary),
      ),
      child: Text(
        tier,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMemberMetric({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.grey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderStatusCard({required List<_OrderShortcut> statuses}) {
    return _profileSurface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: statuses
            .map(
              (status) => Expanded(
                child: _buildOrderShortcut(status),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOrderShortcut(_OrderShortcut shortcut) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            width: 42,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(shortcut.icon, color: AppTheme.black, size: 27),
                if (shortcut.count > 0)
                  Positioned(
                    right: 0,
                    top: -3,
                    child: _buildBadge(shortcut.count),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            shortcut.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityList(List<_ProfileMenuItem> items) {
    return _profileSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              _buildUtilityRow(entry.value),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 48,
                  endIndent: 14,
                  color: AppTheme.greyLight,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUtilityRow(_ProfileMenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(item.icon, color: AppTheme.black, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.grey, size: 22),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 22),
        label: const Text('Đăng xuất'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _profileSurface({
    required Widget child,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  int _orderCount(OrderProvider orderProvider, Set<OrderStatus> statuses) {
    return orderProvider.orders
        .where((order) => statuses.contains(order.status))
        .length;
  }

  int _rewardPoints(OrderProvider orderProvider) {
    return orderProvider.orders.fold<int>(
      0,
      (total, order) => total + (order.total / 10).round(),
    );
  }

  int _voucherCount(int rewardPoints, int cartCount) {
    final rewardVouchers = rewardPoints ~/ 500;
    final cartVouchers = cartCount > 0 ? 1 : 0;
    return (rewardVouchers + cartVouchers).clamp(0, 9).toInt();
  }

  String _membershipTier(AuthProvider auth, int rewardPoints) {
    if (auth.canManageShop) return 'Admin';
    if (rewardPoints >= 2000) return 'Gold';
    if (rewardPoints >= 800) return 'Silver';
    return 'Member';
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final remaining = text.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label đang được cập nhật'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    context.read<CartProvider>().clearLocal();
    _loadedOrdersUserId = null;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _OrderShortcut {
  final IconData icon;
  final String label;
  final int count;

  const _OrderShortcut({
    required this.icon,
    required this.label,
    required this.count,
  });
}
