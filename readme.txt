lib/
├── main.dart
├── firebase_options.dart
│
├── config/
│   ├── app_routes.dart
│   └── app_theme.dart
│
├── models/
│   ├── address_model.dart
│   ├── cart_item_model.dart
│   ├── category_model.dart
│   ├── coupon_model.dart
│   ├── favorite_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   ├── product_variant_model.dart
│   ├── review_model.dart
│   └── user_model.dart
│
├── services/
│   ├── address_service.dart
│   ├── auth_service.dart
│   ├── cart_service.dart
│   ├── category_service.dart
│   ├── coupon_service.dart
│   ├── favorite_service.dart
│   ├── order_service.dart
│   ├── product_service.dart
│   ├── review_service.dart
│   └── user_service.dart
│
├── providers/
│   ├── address_provider.dart
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── category_provider.dart
│   ├── coupon_provider.dart
│   ├── favorite_provider.dart
│   ├── order_provider.dart
│   ├── product_provider.dart
│   ├── review_provider.dart
│   ├── search_provider.dart
│   └── user_provider.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   ├── search_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── payment_method_screen.dart
│   ├── order_confirm_screen.dart
│   ├── order_success_screen.dart
│   ├── order_history_screen.dart
│   ├── order_detail_screen.dart
│   ├── favorites_screen.dart
│   ├── profile_screen.dart
│   ├── profile_info_screen.dart
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   └── admin/
│       └── admin_dashboard_screen.dart
│
├── widgets/
│   ├── common/
│   │   ├── bottom_nav_bar.dart
│   │   ├── loading_widget.dart
│   │   └── primary_button.dart
│   │
│   ├── home/
│   │   ├── banner_slider.dart
│   │   ├── category_section.dart
│   │   └── featured_products.dart
│   │
│   ├── product/
│   │   ├── product_card.dart
│   │   ├── quantity_selector.dart
│   │   ├── rating_stars.dart
│   │   └── review_list.dart
│   │
│   ├── cart/
│   │   ├── cart_item_tile.dart
│   │   └── cart_summary.dart
│   │
│   └── order/
│       ├── order_card.dart
│       └── order_status_badge.dart
│
├── database/
│   ├── mock_data.dart
│   └── seed_firestore.dart
│
└── utils/
    ├── baitap.dart
    ├── constants.dart
    ├── formatters.dart
    └── validators.dart        ← màu, chuỗi, config chung

assets/
├── images/
│   ├── banners/
│   ├── categories/
│   └── products/
└── fonts/

Trang chủ
   ↓
Danh sách sản phẩm
   ↓
Chi tiết sản phẩm
   ↓
Thêm vào giỏ
   ↓
Thanh toán
   ↓
Điền thông tin
   ↓
Chọn phương thức thanh toán
   ↓
Xác nhận đơn
   ↓
Lịch sử mua
   ↓
Chi tiết đơn

✅ lib/config/app_theme.dart
✅ lib/config/app_routes.dart
✅ lib/models/product_model.dart
✅ lib/models/cart_item_model.dart
✅ lib/models/order_model.dart
✅ lib/utils/mock_data.dart
✅ lib/utils/formatters.dart
✅ lib/utils/validators.dart
✅ lib/providers/cart_provider.dart
✅ lib/providers/order_provider.dart
✅ lib/providers/product_provider.dart
✅ lib/main.dart
✅ lib/widgets/common/bottom_nav_bar.dart
✅ lib/widgets/home/banner_slider.dart
✅ lib/widgets/home/category_section.dart
✅ lib/widgets/home/featured_products.dart
✅ lib/widgets/product/product_card.dart
✅ lib/screens/home_screen.dart
✅ lib/screens/product_list_screen.dart
✅ lib/screens/product_detail_screen.dart
✅ lib/screens/cart_screen.dart
✅ lib/screens/checkout_screen.dart
✅ lib/screens/payment_method_screen.dart
✅ lib/screens/order_confirm_screen.dart
✅ lib/screens/order_success_screen.dart
✅ lib/screens/order_history_screen.dart
✅ lib/screens/order_detail_screen.dart
✅ lib/screens/search_screen.dart

//========================================
đã làm hôm nay 31/5
✅ screens/auth/login_screen.dart
✅ screens/auth/register_screen.dart
✅ models/user_model.dart
✅ models/category_model.dart
✅ models/review_model.dart
✅ providers/auth_provider.dart
✅ providers/search_provider.dart
✅ widgets/common/loading_widget.dart
✅ widgets/common/primary_button.dart
✅ widgets/product/quantity_selector.dart
✅ widgets/product/rating_stars.dart
✅ widgets/product/review_list.dart
✅ widgets/cart/cart_item_tile.dart
✅ widgets/cart/cart_summary.dart
✅ widgets/order/order_card.dart
✅ widgets/order/order_status_badge.dart
✅ utils/constants.dart
✅ config/app_routes.dart  (cập nhật)
✅ main.dart               (cập nhật)

cần chỉnh như sau:
1:cập nhật và nâng cấp lại toàn bộ giao diện sao cho nó đẹp hơn và hiệu ứng animation nhìn mượt mà hơn kèm hiệu ứng hover khi tương tác các trang điều hướng.
2:Cập nhật trang uiux đăng ký đăng nhập hiện tại web chưa có, và phần thanh toán thì phần qr sẽ in mã qr, thẻ thì cho form điền thông tin thẻ.
3:Đảm bảo đúng luồng hoạt động và giao dieennj của các luồng phỉa nâng cấp chuẩn giao diện mobile.

luồng : (Lưu ý hiện tại chưa xem được profile các nhân cần cập nhật và tạo thiết kế uiux cho trang các nhân đó)

Trang chủ
   ↓
Danh sách sản phẩm
   ↓
Chi tiết sản phẩm
   ↓
Thêm vào giỏ
   ↓
Thanh toán
   ↓
Điền thông tin
   ↓
Chọn phương thức thanh toán
   ↓
Xác nhận đơn
   ↓
Lịch sử mua
   ↓
Chi tiết đơn
// 1/6 
Đã có Firebase
Đã có dữ liệu sản phẩm và danh mục
Đã có đăng nhập / đăng ký
Đã có phân quyền cơ bản user admin
tài khoản admin mẫu : admin  admin123
Đã có giỏ hàng
Đã có đặt hàng
Trang cá nhân còn đơn giản
Admin dashboard mới là khung
Chưa có chức năng sửa thông tin cá nhân
Chưa có upload ảnh thực tế
Review mới là file note( để vương viết cấm động vào)
Sản phẩm yêu thích chưa có
Mã giảm giá / voucher chưa thật (nên viết mã giảm giá sớm để thiết kế nhiều thứ khác)
Thanh toán chưa thực tế(có thể làm sau)

//====================================================

cải thiện chuẩn giao diện chính sao  cho chuyên nghiệp nhất và các hiệu ứng tương tác mượt nhất

//================================================================================================== 6/4/2026

cập  nhật xong phần login đăng nhập nahnh bằng save và hiển thị thanh toán thành công với những mã qr và form điền thẻ

cập nhật thành công tỉnh thành ở chọn tỉnh thành và quận huyện ứng với nó.
Thêm file address coupon favorite ở back end