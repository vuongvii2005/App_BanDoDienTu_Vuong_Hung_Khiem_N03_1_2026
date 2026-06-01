import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final uid = auth.currentUser?.uid;

    if (uid != null && auth.canBuy && cart.userId != uid && !cart.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<CartProvider>().loadCart(uid);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          if (uid != null && auth.canBuy && cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(uid),
              child: const Text(
                'Xóa',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
      body: uid == null
          ? _buildNeedLogin()
          : !auth.canBuy
              ? _buildRoleBlocked()
              : cart.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : cart.items.isEmpty
                      ? _buildEmpty()
                      : Column(
                          children: [
                            if (cart.error != null)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  cart.error!,
                                  style: const TextStyle(color: AppTheme.error),
                                ),
                              ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _buildCartItem(context, cart, uid, i),
                              ),
                            ),
                            _buildSummary(context, cart),
                          ],
                        ),
    );
  }

  Widget _buildNeedLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 72,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cần đăng nhập để xem giỏ hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildRoleBlocked() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Tài khoản này không dùng để mua hàng',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppTheme.grey),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppTheme.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm sản phẩm vào giỏ để tiếp tục',
            style: TextStyle(color: AppTheme.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    String uid,
    int index,
  ) {
    final item = cart.items[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Checkbox(
            value: true,
            activeColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (_) {},
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 70, height: 70, color: AppTheme.greyLight),
              errorWidget: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppTheme.greyLight,
                child: const Icon(Icons.image_outlined, color: AppTheme.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.selectedStorage.isNotEmpty ||
                    item.selectedColor.isNotEmpty)
                  Text(
                    [item.selectedStorage, item.selectedColor]
                        .where((value) => value.isNotEmpty)
                        .join(' - '),
                    style: const TextStyle(fontSize: 12, color: AppTheme.grey),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.currency(item.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        _qtyButton(
                          Icons.remove,
                          () => cart.decreaseQuantity(uid, item.id),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _qtyButton(
                          Icons.add,
                          () => cart.increaseQuantity(uid, item.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.grey,
              size: 20,
            ),
            onPressed: () => cart.removeItem(uid, item.id),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.greyLight),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _priceRow('Tạm tính', Formatters.currency(cart.subtotal)),
          if (cart.discount > 0)
            _priceRow(
              'Giảm giá (WELCOME10)',
              '-${Formatters.currency(cart.discount)}',
              valueColor: AppTheme.error,
            ),
          _priceRow(
            'Phí vận chuyển',
            cart.shippingFee == 0
                ? 'Miễn phí'
                : Formatters.currency(cart.shippingFee),
            valueColor: cart.shippingFee == 0 ? AppTheme.success : null,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
            child: Text('Thanh toán (${cart.itemCount})'),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}
