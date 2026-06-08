// quản lý đường dẫn màn hình
import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/order_confirm_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/payment_method_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_info_screen.dart';
import '../screens/address_screen.dart';
import '../screens/coupon_screen.dart';
import '../screens/support_screen.dart';
import '../screens/settings_screen.dart';

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
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String login = '/login';
  static const String register = '/register';
  static const String admin = '/admin';
  static const String profileInfo = '/profile-info';
  static const String address = '/address';
  static const String coupon = '/coupon';
  static const String support = '/support';
  static const String settings = '/settings';
  static const String notification = '/notification';
  static const String membership = '/membership';

  static String _orderIdFromArguments(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      return args;
    }

    if (args is Map) {
      final value = args['orderId'] ?? args['id'];
      if (value != null) {
        return value.toString();
      }
    }

    debugPrint(
      'Missing orderId argument for ${ModalRoute.of(context)?.settings.name}',
    );
    return '';
  }

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        productList: (ctx) => ProductListScreen(
              categoryId: ModalRoute.of(ctx)!.settings.arguments as String?,
            ),
        productDetail: (ctx) => ProductDetailScreen(
              productId: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
        cart: (_) => const CartScreen(),
        checkout: (_) => const CheckoutScreen(),
        paymentMethod: (_) => const PaymentMethodScreen(),
        orderConfirm: (_) => const OrderConfirmScreen(),
        orderSuccess: (ctx) => OrderSuccessScreen(
              orderId: _orderIdFromArguments(ctx),
            ),
        orderHistory: (_) => const OrderHistoryScreen(),
        orderDetail: (ctx) => OrderDetailScreen(
              orderId: _orderIdFromArguments(ctx),
            ),
        favorites: (_) => const FavoritesScreen(),
        search: (_) => const SearchScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        admin: (_) => const AdminDashboardScreen(),
        profileInfo: (_) => const ProfileInfoScreen(),
        address: (_) => const AddressScreen(),
        coupon: (_) => const CouponScreen(),
        support: (_) => const SupportScreen(),
        settings: (_) => const SettingsScreen(),
        notification: (_) => const NotificationScreen(),
        membership: (_) => const MembershipScreen(),
      };
}
