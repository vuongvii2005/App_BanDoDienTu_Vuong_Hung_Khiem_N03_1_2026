import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final order = _statusInfo(status);
    final color = order['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order['label'] as String,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Map<String, dynamic> _statusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return {'label': 'Chờ xác nhận', 'color': const Color(0xFFFF9800)};
      case OrderStatus.confirmed:
        return {'label': 'Đã xác nhận', 'color': const Color(0xFF2196F3)};
      case OrderStatus.shipping:
        return {'label': 'Đang giao', 'color': const Color(0xFF9C27B0)};
      case OrderStatus.completed:
        return {'label': 'Hoàn thành', 'color': const Color(0xFF4CAF50)};
      case OrderStatus.cancelled:
        return {'label': 'Đã hủy', 'color': const Color(0xFFF44336)};
    }
  }
}
