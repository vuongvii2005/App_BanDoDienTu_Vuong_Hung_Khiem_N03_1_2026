import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class MockData {
  // ======= PRODUCTS =======
  static List<Product> products = [
    Product(
      id: '1',
      name: 'iPhone 15 Pro Max',
      category: 'Điện thoại',
      price: 1199,
      rating: 4.8,
      reviewCount: 256,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-naturaltitanium?wid=400&hei=400&fmt=jpeg',
      description:
          'iPhone 15 Pro Max với chip A17 Pro mạnh mẽ, camera 48MP và thiết kế titan cao cấp.',
      storage: ['256GB', '512GB', '1TB'],
      colors: ['Titan Tự nhiên', 'Titan Đen', 'Titan Trắng', 'Titan Xanh'],
      isFeatured: true,
    ),
    Product(
      id: '2',
      name: 'AirPods Pro 2',
      category: 'Tai nghe',
      price: 249,
      rating: 4.7,
      reviewCount: 189,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=400&hei=400&fmt=jpeg',
      description: 'AirPods Pro 2 với USB-C, chống ồn chủ động thế hệ mới.',
      storage: [],
      colors: ['Trắng'],
      isFeatured: true,
    ),
    Product(
      id: '3',
      name: 'Samsung Galaxy S24 Ultra',
      category: 'Điện thoại',
      price: 1099,
      rating: 4.6,
      reviewCount: 408,
      imageUrl:
          r'https://images.samsung.com/is/image/samsung/p6pim/levant/2401/gallery/levant-galaxy-s24-ultra-s928-sm-s928bzkgmid-thumb-539573050?$344_344_PNG$',
      description:
          'Samsung Galaxy S24 Ultra với bút S Pen tích hợp và camera 200MP.',
      storage: ['256GB', '512GB'],
      colors: ['Đen', 'Xám', 'Tím', 'Vàng'],
      isFeatured: false,
    ),
    Product(
      id: '4',
      name: 'Xiaomi 14 Pro',
      category: 'Điện thoại',
      price: 899,
      rating: 4.5,
      reviewCount: 312,
      imageUrl:
          'https://i02.appmifile.com/mi-com-product/fly-birds/xiaomi-14/xiaomi14-phone.png',
      description: 'Xiaomi 14 Pro với Snapdragon 8 Gen 3 và camera Leica.',
      storage: ['256GB', '512GB'],
      colors: ['Đen', 'Trắng', 'Xanh'],
      isFeatured: false,
    ),
    Product(
      id: '5',
      name: 'iPhone 14 Pro',
      category: 'Điện thoại',
      price: 999,
      rating: 4.7,
      reviewCount: 521,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-14-pro-finish-select-202209-6-1inch-deeppurple?wid=400&hei=400&fmt=jpeg',
      description: 'iPhone 14 Pro với Dynamic Island và chip A16 Bionic.',
      storage: ['128GB', '256GB', '512GB', '1TB'],
      colors: ['Tím đậm', 'Vàng', 'Bạc', 'Đen không gian'],
      isFeatured: false,
    ),
    Product(
      id: '6',
      name: 'Apple Watch Series 9',
      category: 'Đồng hồ',
      price: 399,
      rating: 4.8,
      reviewCount: 167,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQDY3ref_VW_34FR+watch-45-alum-midnight-nc-9s_VW_34FR_WF_CO?wid=400&hei=400&fmt=jpeg',
      description: 'Apple Watch Series 9 với chip S9 và tính năng Double Tap.',
      storage: [],
      colors: ['Midnight', 'Starlight', 'Đỏ', 'Hồng', 'Bạc'],
      isFeatured: false,
    ),
    Product(
      id: '7',
      name: 'MacBook Pro 14"',
      category: 'Laptop',
      price: 1999,
      rating: 4.9,
      reviewCount: 203,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mbp14-spacegray-select-202301?wid=400&hei=400&fmt=jpeg',
      description: 'MacBook Pro 14 inch với chip M3 Pro mạnh mẽ.',
      storage: ['512GB', '1TB', '2TB'],
      colors: ['Xám không gian', 'Bạc'],
      isFeatured: true,
    ),
  ];

  // ======= CATEGORIES =======
  static List<Map<String, String>> categories = [
    {'name': 'Điện thoại', 'icon': '📱'},
    {'name': 'Laptop', 'icon': '💻'},
    {'name': 'Tai nghe', 'icon': '🎧'},
    {'name': 'Đồng hồ', 'icon': '⌚'},
    {'name': 'Phụ kiện', 'icon': '🔌'},
  ];

  // ======= BANNERS =======
  static List<Map<String, String>> banners = [
    {
      'title': 'CÔNG NGHỆ\nĐỈNH CAO',
      'subtitle': 'Trải nghiệm tuyệt vời',
      'imageUrl':
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=600&hei=300&fmt=jpeg',
    },
    {
      'title': 'SAMSUNG\nGALAXY S24',
      'subtitle': 'Siêu phẩm mới nhất',
      'imageUrl':
          'https://images.samsung.com/is/image/samsung/p6pim/levant/2401/gallery/levant-galaxy-s24-ultra-s928-sm-s928bzkgmid-thumb-539573050?wid=600&hei=300',
    },
  ];

  // ======= MOCK ORDERS =======
  static List<Order> orders = [
    Order(
      id: 'TS2505189321',
      items: [
        CartItem(
            id: '1',
            product: products[0],
            quantity: 1,
            selectedStorage: '256GB',
            selectedColor: 'Titan Tự nhiên'),
        CartItem(
            id: '2',
            product: products[1],
            quantity: 1,
            selectedStorage: '',
            selectedColor: 'Trắng'),
        CartItem(
            id: '3',
            product: products[5],
            quantity: 1,
            selectedStorage: '',
            selectedColor: 'Midnight'),
      ],
      subtotal: 1847,
      discount: 184.70,
      shippingFee: 0,
      total: 1662.30,
      paymentMethod: 'Ví MoMo',
      shippingAddress:
          'Vương Hùng Khiêm\n123 Nguyễn Văn Cừ, Phường 1, Quận 5, TP. Hồ Chí Minh\n0901 234 567',
      status: OrderStatus.completed,
      createdAt: DateTime(2025, 5, 18, 21, 41),
    ),
    Order(
      id: 'TS2505157840',
      items: [
        CartItem(
            id: '4',
            product: products[2],
            quantity: 1,
            selectedStorage: '256GB',
            selectedColor: 'Đen'),
      ],
      subtotal: 899,
      total: 899,
      paymentMethod: 'COD',
      shippingAddress: 'Vương Hùng Khiêm\n123 Nguyễn Văn Cừ',
      status: OrderStatus.shipping,
      createdAt: DateTime(2025, 5, 15),
    ),
    Order(
      id: 'TS2505124567',
      items: [
        CartItem(
            id: '5',
            product: products[1],
            quantity: 1,
            selectedStorage: '',
            selectedColor: 'Trắng'),
      ],
      subtotal: 249,
      total: 249,
      paymentMethod: 'Thẻ tín dụng',
      shippingAddress: 'Vương Hùng Khiêm\n123 Nguyễn Văn Cừ',
      status: OrderStatus.cancelled,
      createdAt: DateTime(2025, 5, 12),
    ),
  ];
}
