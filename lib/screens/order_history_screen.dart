import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../models/order_model.dart';
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

  final _tabs = [
    {'label': 'Tất cả', 'status': null},
    {'label': 'Chờ xác nhận', 'status': OrderStatus.pending},
    {'label': 'Đang giao', 'status': OrderStatus.shipping},
    {'label': 'Hoàn thành', 'status': OrderStatus.completed},
  ];

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final filtered = _filter == null
        ? orders
        : orders.where((o) => o.status == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: AppTheme.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: _tabs.map((t) {
                  final isActive = _filter == t['status'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _filter = t['status'] as OrderStatus?),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primary
                              : AppTheme.greyLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive ? Colors.white : AppTheme.grey,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Không có đơn hàng',
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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
            // Header
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

            // Product images preview
            Row(
              children: [
                // Thumbnails
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Stack(
                      children: order.items
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (e) => Positioned(
                              left: e.key * 38.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: e.value.product.imageUrl,
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
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Price + item count
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

  Widget _statusBadge(Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.12),
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
