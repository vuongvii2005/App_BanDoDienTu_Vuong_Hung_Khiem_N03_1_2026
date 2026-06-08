// giữ dữ liệu banner còn lại xóa cũng được
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class MockData {
  // Chỉ giữ để tham khảo và seed dữ liệu mẫu. Provider chính không đọc file này.
  static List<Product> products = [
    Product(
      id: 'iphone-15-pro-max',
      name: 'iPhone 15 Pro Max',
      brand: 'Apple',
      categoryId: 'phone',
      minPrice: 26990000,
      maxPrice: 32990000,
      totalStock: 20,
      rating: 4.8,
      reviewCount: 256,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-naturaltitanium?wid=400&hei=400&fmt=jpeg',
      images: [
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-naturaltitanium?wid=400&hei=400&fmt=jpeg',
      ],
      description:
          'Điện thoại cao cấp với hiệu năng mạnh, thiết kế sang trọng và camera 48MP.',
      isFeatured: true,
      isHotDeal: true,
      salePrice: 24990000,
      dealStartAt: DateTime(2026, 1, 1),
      dealEndAt: DateTime(2026, 12, 31, 23, 59, 59),
      dealSold: 12,
      dealStock: 20,
    ),
    Product(
      id: 'airpods-pro-2',
      name: 'AirPods Pro 2',
      brand: 'Apple',
      categoryId: 'headphone',
      minPrice: 5990000,
      maxPrice: 5990000,
      totalStock: 30,
      rating: 4.7,
      reviewCount: 189,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=400&hei=400&fmt=jpeg',
      images: [
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=400&hei=400&fmt=jpeg',
      ],
      description: 'Tai nghe không dây có chống ồn chủ động.',
      isFeatured: true,
      isHotDeal: true,
      salePrice: 4990000,
      dealStartAt: DateTime(2026, 1, 1),
      dealEndAt: DateTime(2026, 12, 31, 23, 59, 59),
      dealSold: 24,
      dealStock: 35,
    ),
    Product(
      id: 'galaxy-s24-ultra',
      name: 'Samsung Galaxy S24 Ultra',
      brand: 'Samsung',
      categoryId: 'phone',
      minPrice: 22590000,
      maxPrice: 28590000,
      totalStock: 18,
      rating: 4.6,
      reviewCount: 408,
      imageUrl:
          'https://images.samsung.com/is/image/samsung/p6pim/levant/2401/gallery/levant-galaxy-s24-ultra-s928-sm-s928bzkgmid-thumb-539573050?\$344_344_PNG\$',
      description: 'Điện thoại Android cao cấp với bút S Pen và camera 200MP.',
      isFeatured: false,
    ),
    Product(
      id: 'macbook-pro-14',
      name: 'MacBook Pro 14',
      brand: 'Apple',
      categoryId: 'laptop',
      minPrice: 39990000,
      maxPrice: 45990000,
      totalStock: 10,
      rating: 4.9,
      reviewCount: 203,
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/mbp14-spacegray-select-202301?wid=400&hei=400&fmt=jpeg',
      description: 'Laptop chuyên nghiệp nhỏ gọn dùng chip Apple silicon.',
      isFeatured: true,
    ),
  ];

  static List<CategoryModel> categoryModels = const [
    CategoryModel(id: 'phone', name: 'Điện thoại', icon: 'P', sortOrder: 1),
    CategoryModel(id: 'laptop', name: 'Laptop', icon: 'L', sortOrder: 2),
    CategoryModel(id: 'tablet', name: 'Máy tính bảng', icon: 'T', sortOrder: 3),
    CategoryModel(id: 'headphone', name: 'Tai nghe', icon: 'H', sortOrder: 4),
    CategoryModel(
        id: 'watch', name: 'Đồng hồ thông minh', icon: 'W', sortOrder: 5),
    CategoryModel(id: 'accessory', name: 'Phụ kiện', icon: 'A', sortOrder: 6),
  ];

  static List<Map<String, String>> categories = categoryModels
      .map((category) => {
            'id': category.id,
            'name': category.name,
            'icon': category.icon,
          })
      .toList();

  static List<Map<String, String>> banners = [
    {
      'title': 'ƯU ĐÃI CÔNG NGHỆ',
      'subtitle': 'Sản phẩm điện tử nổi bật',
      'imageUrl':
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=600&hei=300&fmt=jpeg',
    },
    {
      'title': 'GALAXY S24',
      'subtitle': 'Điện thoại cao cấp mới',
      'imageUrl':
          'https://images.samsung.com/is/image/samsung/p6pim/levant/2401/gallery/levant-galaxy-s24-ultra-s928-sm-s928bzkgmid-thumb-539573050?wid=600&hei=300',
    },
  ];

  static List<OrderModel> orders = [
    OrderModel(
      id: 'TS2505189321',
      userId: 'demo-user',
      items: [
        OrderItem.fromMap({
          'productId': products[0].id,
          'productName': products[0].name,
          'imageUrl': products[0].imageUrl,
          'price': products[0].price,
          'quantity': 1,
          'selectedStorage': '256GB',
          'selectedColor': 'Titan tự nhiên',
        }),
        OrderItem.fromMap({
          'productId': products[1].id,
          'productName': products[1].name,
          'imageUrl': products[1].imageUrl,
          'price': products[1].price,
          'quantity': 1,
          'selectedStorage': '',
          'selectedColor': 'Trắng',
        }),
      ],
      subtotal: 32980000,
      discount: 3298000,
      shippingFee: 0,
      total: 29682000,
      paymentMethod: 'COD',
      shippingAddress: 'Địa chỉ mẫu',
      phone: '0901234567',
      status: OrderStatus.completed,
      createdAt: DateTime(2025, 5, 18, 21, 41),
    ),
  ];
}
