class AppConstants {
  // App info
  static const String appName = 'Tech Store';
  static const String appVersion = '1.0.0';

  // Coupon
  static const String defaultCoupon = 'WELCOME10';
  static const int discountMin = 1000000;
  static const int discountPercent = 10;

  // Shipping
  static const int freeShippingMin = 500000;
  static const int shippingFee = 30000;

  // Pagination
  static const int pageSize = 10;

  // Shared prefs keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyCartData = 'cart_data';
}
