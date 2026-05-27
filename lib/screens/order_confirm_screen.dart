import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';

class OrderConfirmScreen extends StatelessWidget {
  const OrderConfirmScreen({super.key});

  String _paymentLabel(String id) {
    switch (id) {
      case 'COD':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'CARD':
        return 'Thẻ tín dụng / Ghi nợ';
      case 'MOMO':
        return 'Ví MoMo';
      case 'BANK':
        return 'Chuyển khoản ngân hàng';
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final paymentMethod =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'COD';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Shipping info
            _buildSection(
              title: 'Thông tin giao hàng',
              action: 'Sửa',
              onAction: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vương Hùng Khiêm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '123 Nguyễn Văn Cừ, Phường 1,\nQuận 5, TP. Hồ Chí Minh',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0901 234 567',
                      style: TextStyle(fontSize: 13, color: AppTheme.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment method
            _buildSection(
              title: 'Phương thức thanh toán',
              action: 'Sửa',
              onAction: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Color(0xFFE91E8C),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _paymentLabel(paymentMethod),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Products
            _buildSection(
              title: 'Sản phẩm (${cart.items.length})',
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item.product.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 56,
                            height: 56,
                            color: AppTheme.greyLight,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: AppTheme.greyLight,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppTheme.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.selectedStorage.isNotEmpty)
                              Text(
                                item.selectedStorage,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(item.product.price),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Price summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _priceRow('Tạm tính', Formatters.currency(cart.subtotal)),
                  if (cart.discount > 0)
                    _priceRow(
                      'Giảm giá (WELCOME10)',
                      '-${Formatters.currency(cart.discount)}',
                      color: AppTheme.error,
                    ),
                  _priceRow(
                    'Phí vận chuyển',
                    cart.shippingFee == 0
                        ? 'Miễn phí'
                        : Formatters.currency(cart.shippingFee),
                    color: cart.shippingFee == 0 ? AppTheme.success : null,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        Formatters.currency(cart.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        color: AppTheme.white,
        child: ElevatedButton.icon(
          onPressed: () {
            final orderId = context.read<OrderProvider>().placeOrder(
              items: cart.items,
              subtotal: cart.subtotal,
              discount: cart.discount,
              shippingFee: cart.shippingFee,
              total: cart.total,
              paymentMethod: _paymentLabel(paymentMethod),
              shippingAddress:
                  'Vương Hùng Khiêm\n123 Nguyễn Văn Cừ, Phường 1, Quận 5, TP. Hồ Chí Minh\n0901 234 567',
            );
            context.read<CartProvider>().clear();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orderSuccess,
              (r) => r.settings.name == AppRoutes.home,
              arguments: orderId,
            );
          },
          icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
          label: const Text('Đặt hàng'),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? action,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (action != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(
                      action,
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}
