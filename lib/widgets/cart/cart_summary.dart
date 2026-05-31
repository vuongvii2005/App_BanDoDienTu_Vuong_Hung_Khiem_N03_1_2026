import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';

class CartSummary extends StatelessWidget {
  final CartProvider cart;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        children: [
          _row('Tạm tính', Formatters.currency(cart.subtotal)),
          if (cart.discount > 0)
            _row('Giảm giá', '-${Formatters.currency(cart.discount)}',
                valueColor: AppTheme.error),
          _row(
              'Phí vận chuyển',
              cart.shippingFee == 0
                  ? 'Miễn phí'
                  : Formatters.currency(cart.shippingFee),
              valueColor: cart.shippingFee == 0 ? AppTheme.success : null),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(Formatters.currency(cart.total),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onCheckout,
            child: Text('Thanh toán (${cart.itemCount})'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppTheme.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.black)),
        ],
      ),
    );
  }
}
