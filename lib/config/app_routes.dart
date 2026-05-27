import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/payment_method_screen.dart';
import '../screens/order_confirm_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/search_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String productList = '/product-list';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentMethod = '/payment-method';
  static const String orderConfirm = '/order-confirm';
  static const String orderSuccess = '/order-success';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String search = '/search';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    productList: (ctx) => ProductListScreen(
      category: ModalRoute.of(ctx)!.settings.arguments as String? ?? 'Tất cả',
    ),
    productDetail: (ctx) => ProductDetailScreen(
      productId: ModalRoute.of(ctx)!.settings.arguments as String,
    ),
    cart: (_) => const CartScreen(),
    checkout: (_) => const CheckoutScreen(),
    paymentMethod: (_) => const PaymentMethodScreen(),
    orderConfirm: (_) => const OrderConfirmScreen(),
    orderSuccess: (ctx) => OrderSuccessScreen(
      orderId: ModalRoute.of(ctx)!.settings.arguments as String,
    ),
    orderHistory: (_) => const OrderHistoryScreen(),
    orderDetail: (ctx) => OrderDetailScreen(
      orderId: ModalRoute.of(ctx)!.settings.arguments as String,
    ),
    search: (_) => const SearchScreen(),
  };
}
