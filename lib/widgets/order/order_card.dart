import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../utils/formatters.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                Text('#${order.id}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(Formatters.date(order.createdAt),
                style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
            const SizedBox(height: 12),
            // Thumbnails
            SizedBox(
              height: 50,
              child: Stack(
                children: order.items
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => Positioned(
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
                                  color: AppTheme.greyLight),
                              errorWidget: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppTheme.greyLight),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} sản phẩm',
                    style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                Text(Formatters.currency(order.total),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
