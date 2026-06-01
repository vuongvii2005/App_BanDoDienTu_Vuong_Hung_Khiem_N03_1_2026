import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';
import '../widgets/common/bottom_nav_bar.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  OrderStatus? _filter;
  int _navIndex = 3;
  String? _loadedUserId;

  final _tabs = [
    {'label': 'Tất cả', 'status': null},
    {'label': 'Chờ xác nhận', 'status': OrderStatus.pending},
    {'label': 'Đang giao', 'status': OrderStatus.shipping},
    {'label': 'Hoàn thành', 'status': OrderStatus.completed},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final uid = auth.currentUser?.uid;

    if (uid != null &&
        auth.canBuy &&
        _loadedUserId != uid &&
        !orderProvider.isLoading) {
      _loadedUserId = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<OrderProvider>().loadOrders(uid);
      });
    }

    final filtered = _filter == null
        ? orderProvider.orders
        : orderProvider.orders
            .where((order) => order.status == _filter)
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: uid == null
          ? _needLogin()
          : !auth.canBuy
              ? _roleBlocked()
              : Column(
                  children: [
                    _filterTabs(),
                    Expanded(
                      child: orderProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            )
                          : filtered.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Không có đơn hàng',
                                    style: TextStyle(color: AppTheme.grey),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) =>
                                      _buildOrderCard(context, filtered[i]),
                                ),
                    ),
                  ],
                ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.cart);
          if (i == 4) {
            if (uid == null) {
              Navigator.pushNamed(context, AppRoutes.login);
            } else if (auth.canManageShop) {
              Navigator.pushNamed(context, AppRoutes.admin);
            }
          }
        },
      ),
    );
  }

  Widget _needLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cần đăng nhập để xem đơn hàng',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBlocked() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Tài khoản này không dùng để mua hàng',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grey),
        ),
      ),
    );
  }

  Widget _filterTabs() {
    return Container(
      color: AppTheme.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: _tabs.map((tab) {
            final isActive = _filter == tab['status'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _filter = tab['status'] as OrderStatus?),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.greyLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? Colors.white : AppTheme.grey,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _statusBadge(order),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.date(order.createdAt),
              style: const TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: Stack(
                children: order.items.take(3).toList().asMap().entries.map(
                  (entry) {
                    return Positioned(
                      left: entry.key * 38.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: entry.value.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 50,
                            height: 50,
                            color: AppTheme.greyLight,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: AppTheme.greyLight,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} sản phẩm',
                  style: const TextStyle(fontSize: 12, color: AppTheme.grey),
                ),
                Text(
                  Formatters.currency(order.total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: order.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: order.statusColor,
        ),
      ),
    );
  }
}
