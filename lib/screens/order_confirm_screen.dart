import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
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
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final args = _routeArgs(context);
    final paymentMethod = args['paymentMethod'] ?? 'COD';
    final shippingInfo =
        args['shippingInfo'] as Map<String, String>? ?? <String, String>{};

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: auth.isGuest
          ? const Center(
              child: Text(
                'Cần đăng nhập để đặt hàng',
                style: TextStyle(color: AppTheme.grey),
              ),
            )
          : !auth.canBuy
              ? const Center(
                  child: Text(
                    'Tài khoản này không dùng để mua hàng',
                    style: TextStyle(color: AppTheme.grey),
                  ),
                )
              : cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Giỏ hàng đang trống',
                        style: TextStyle(color: AppTheme.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSection(
                            title: 'Thông tin giao hàng',
                            action: 'Sửa',
                            onAction: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shippingInfo['fullName'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shippingInfo['address'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.grey,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shippingInfo['phone'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                      color: const Color(0xFFE91E8C)
                                          .withValues(alpha: 0.1),
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
                                  Expanded(
                                    child: Text(
                                      _paymentLabel(paymentMethod),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            title: 'Sản phẩm (${cart.items.length})',
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(14),
                              itemCount: cart.items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 16),
                              itemBuilder: (_, i) {
                                final item = cart.items[i];
                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: item.imageUrl,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          Formatters.currency(item.price),
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
                          _priceSummary(cart),
                          if (orderProvider.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              orderProvider.error!,
                              style: const TextStyle(color: AppTheme.error),
                            ),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
      bottomNavigationBar: _buildBottom(
        context,
        auth,
        cart,
        orderProvider,
        paymentMethod,
        shippingInfo,
      ),
    );
  }

  Widget _buildBottom(
    BuildContext context,
    AuthProvider auth,
    CartProvider cart,
    OrderProvider orderProvider,
    String paymentMethod,
    Map<String, String> shippingInfo,
  ) {
    final uid = auth.currentUser?.uid;
    final canOrder = auth.canBuy &&
        uid != null &&
        cart.items.isNotEmpty &&
        !orderProvider.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      color: AppTheme.white,
      child: ElevatedButton.icon(
        onPressed: canOrder
            ? () async {
                final orderId = await context.read<OrderProvider>().placeOrder(
                      userId: uid,
                      items: cart.items,
                      subtotal: cart.subtotal,
                      discount: cart.discount,
                      shippingFee: cart.shippingFee,
                      total: cart.total,
                      paymentMethod: _paymentLabel(paymentMethod),
                      shippingAddress: shippingInfo['address'] ?? '',
                      phone: shippingInfo['phone'] ?? '',
                    );

                if (orderId == null || !context.mounted) return;
                context.read<CartProvider>().clearLocal();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.orderSuccess,
                  (route) => route.settings.name == AppRoutes.home,
                  arguments: orderId,
                );
              }
            : null,
        icon: orderProvider.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.lock_outline, color: Colors.white, size: 18),
        label: const Text('Đặt hàng'),
      ),
    );
  }

  Widget _priceSummary(CartProvider cart) {
    return Container(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  Map<String, dynamic> _routeArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final rawShipping = args['shippingInfo'];
      return {
        'paymentMethod': args['paymentMethod']?.toString() ?? 'COD',
        'shippingInfo': rawShipping is Map
            ? rawShipping.map(
                (key, value) => MapEntry(
                  key.toString(),
                  value?.toString() ?? '',
                ),
              )
            : <String, String>{},
      };
    }
    return {
      'paymentMethod': 'COD',
      'shippingInfo': <String, String>{},
    };
  }
}
