//file đẩy data mẫu lên Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestoreData() async {
  final firestore = FirebaseFirestore.instance;

  final categoryBatch = firestore.batch();
  for (final category in _categories) {
    final docRef =
        firestore.collection('categories').doc(category['id'] as String);
    categoryBatch.set(docRef, category, SetOptions(merge: true));
  }
  await categoryBatch.commit();

  final productBatch = firestore.batch();
  for (final product in _products) {
    final docRef =
        firestore.collection('products').doc(product['id'] as String);
    final productDoc = Map<String, dynamic>.from(product)..remove('_variants');
    productDoc.addAll({
      'price': FieldValue.delete(),
      'oldPrice': FieldValue.delete(),
      'stock': FieldValue.delete(),
      'storageOptions': FieldValue.delete(),
      'colorOptions': FieldValue.delete(),
    });
    productBatch.set(docRef, productDoc, SetOptions(merge: true));
  }
  await productBatch.commit();

  final variantBatch = firestore.batch();
  for (final product in _products) {
    final productId = product['id'] as String;
    final variants =
        (product['_variants'] as List).cast<Map<String, dynamic>>();
    for (final variant in variants) {
      final docRef = firestore
          .collection('products')
          .doc(productId)
          .collection('variants')
          .doc(variant['id'] as String);
      variantBatch.set(docRef, variant, SetOptions(merge: true));
    }
  }
  await variantBatch.commit();
}

final _now = FieldValue.serverTimestamp();

const Map<String, String> _categoryImageLinks = {
  'phone':
      'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-1-1.jpg',
  'laptop':
      'https://cdn.tgdd.vn/Products/Images/44/282827/apple-macbook-air-m2-2022-01.jpg',
  'tablet':
      'https://cdn.tgdd.vn/Products/Images/522/325534/ipad-pro-13-inch-m4-lte-black-1.jpg',
  'headphone':
      'https://cdn.tgdd.vn/Products/Images/54/289781/airpods-pro-2nd-generation-0.jpg',
  'watch':
      'https://cdn.tgdd.vn/Products/Images/7077/314708/apple-watch-s9-45mm-vien-nhom-day-silicone-trang-starlight-1.jpg',
  'accessory':
      'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-1-org.jpg',
};

final List<Map<String, dynamic>> _categories = [
  _category('phone', 'Điện thoại', 'P', 1),
  _category('laptop', 'Laptop', 'L', 2),
  _category('tablet', 'Máy tính bảng', 'T', 3),
  _category('headphone', 'Tai nghe', 'H', 4),
  _category('watch', 'Đồng hồ thông minh', 'W', 5),
  _category('accessory', 'Phụ kiện', 'A', 6),
];

Map<String, dynamic> _category(
  String id,
  String name,
  String icon,
  int sortOrder,
) {
  return {
    'id': id,
    'name': name,
    'icon': icon,
    'imageUrl': _categoryImageLinks[id] ?? '',
    'sortOrder': sortOrder,
    'isActive': true,
    'createdAt': _now,
    'updatedAt': _now,
  };
}

final List<Map<String, dynamic>> _products = [
  _product(
    id: 'iphone-15-pro-max',
    name: 'iPhone 15 Pro Max',
    brand: 'Apple',
    categoryId: 'phone',
    price: 26990000,
    oldPrice: 29990000,
    description:
        'Điện thoại cao cấp với chip A17 Pro, camera 48MP và khung titan.',
    storageOptions: ['256GB', '512GB', '1TB'],
    colorOptions: ['Titan tự nhiên', 'Titan đen', 'Titan trắng', 'Titan xanh'],
    stock: 20,
    rating: 4.8,
    reviewCount: 256,
    isFeatured: true,
  ),
  _product(
    id: 'iphone-15',
    name: 'iPhone 15',
    brand: 'Apple',
    categoryId: 'phone',
    price: 17890000,
    oldPrice: 19990000,
    description:
        'iPhone màn hình Super Retina XDR, Dynamic Island và camera kép.',
    storageOptions: ['128GB', '256GB', '512GB'],
    colorOptions: ['Đen', 'Xanh', 'Hồng', 'Vàng'],
    stock: 35,
    rating: 4.7,
    reviewCount: 180,
    isFeatured: true,
  ),
  _product(
    id: 'samsung-galaxy-s24-ultra',
    name: 'Samsung Galaxy S24 Ultra',
    brand: 'Samsung',
    categoryId: 'phone',
    price: 22590000,
    oldPrice: 30990000,
    description: 'Flagship Android với bút S Pen, Galaxy AI và camera 200MP.',
    storageOptions: ['256GB', '512GB', '1TB'],
    colorOptions: ['Đen', 'Xám', 'Tím', 'Vàng'],
    stock: 18,
    rating: 4.7,
    reviewCount: 210,
    isFeatured: true,
  ),
  _product(
    id: 'xiaomi-14',
    name: 'Xiaomi 14',
    brand: 'Xiaomi',
    categoryId: 'phone',
    price: 18990000,
    oldPrice: 0,
    description: 'Điện thoại nhỏ gọn, hiệu năng mạnh với Snapdragon cao cấp.',
    storageOptions: ['256GB', '512GB'],
    colorOptions: ['Đen', 'Trắng', 'Xanh'],
    stock: 24,
    rating: 4.6,
    reviewCount: 124,
  ),
  _product(
    id: 'oppo-reno-11',
    name: 'OPPO Reno 11',
    brand: 'OPPO',
    categoryId: 'phone',
    price: 8990000,
    oldPrice: 9990000,
    description: 'Điện thoại tầm trung có camera chân dung đẹp và sạc nhanh.',
    storageOptions: ['128GB', '256GB'],
    colorOptions: ['Xám', 'Xanh ngọc'],
    stock: 30,
    rating: 4.5,
    reviewCount: 96,
  ),
  _product(
    id: 'macbook-air-m2',
    name: 'MacBook Air M2',
    brand: 'Apple',
    categoryId: 'laptop',
    price: 19990000,
    oldPrice: 29990000,
    description: 'Laptop mỏng nhẹ, pin lâu, phù hợp học tập và làm việc.',
    storageOptions: ['256GB', '512GB'],
    colorOptions: ['Midnight', 'Starlight', 'Bạc', 'Xám không gian'],
    stock: 16,
    rating: 4.8,
    reviewCount: 142,
    isFeatured: true,
  ),
  _product(
    id: 'macbook-pro-m3',
    name: 'MacBook Pro M3',
    brand: 'Apple',
    categoryId: 'laptop',
    price: 39990000,
    oldPrice: 45990000,
    description:
        'Laptop hiệu năng cao với chip M3 và màn hình Liquid Retina XDR.',
    storageOptions: ['512GB', '1TB', '2TB'],
    colorOptions: ['Bạc', 'Xám không gian'],
    stock: 12,
    rating: 4.9,
    reviewCount: 98,
    isFeatured: true,
  ),
  _product(
    id: 'dell-xps-13',
    name: 'Dell XPS 13',
    brand: 'Dell',
    categoryId: 'laptop',
    price: 37490000,
    oldPrice: 41990000,
    description: 'Laptop Windows cao cấp, thiết kế mỏng và màn hình sắc nét.',
    storageOptions: ['512GB', '1TB'],
    colorOptions: ['Bạc', 'Đen'],
    stock: 10,
    rating: 4.6,
    reviewCount: 87,
  ),
  _product(
    id: 'asus-rog-zephyrus-g14',
    name: 'ASUS ROG Zephyrus G14',
    brand: 'ASUS',
    categoryId: 'laptop',
    price: 54990000,
    oldPrice: 59990000,
    description:
        'Laptop gaming 14 inch mạnh mẽ, phù hợp chơi game và sáng tạo.',
    storageOptions: ['1TB', '2TB'],
    colorOptions: ['Trắng', 'Xám'],
    stock: 8,
    rating: 4.7,
    reviewCount: 73,
  ),
  _product(
    id: 'lenovo-thinkpad-x1-carbon',
    name: 'Lenovo ThinkPad X1 Carbon',
    brand: 'Lenovo',
    categoryId: 'laptop',
    price: 60990000,
    oldPrice: 62990000,
    description: 'Laptop doanh nhân bền nhẹ, bàn phím tốt và bảo mật cao.',
    storageOptions: ['512GB', '1TB'],
    colorOptions: ['Đen'],
    stock: 14,
    rating: 4.7,
    reviewCount: 65,
  ),
  _product(
    id: 'ipad-pro-m4',
    name: 'iPad Pro M4',
    brand: 'Apple',
    categoryId: 'tablet',
    price: 32990000,
    oldPrice: 37990000,
    description:
        'Máy tính bảng cao cấp với chip M4 và màn hình Ultra Retina XDR.',
    storageOptions: ['256GB', '512GB', '1TB'],
    colorOptions: ['Bạc', 'Đen không gian'],
    stock: 15,
    rating: 4.9,
    reviewCount: 88,
    isFeatured: true,
  ),
  _product(
    id: 'ipad-air-5',
    name: 'iPad Air 5',
    brand: 'Apple',
    categoryId: 'tablet',
    price: 12990000,
    oldPrice: 16990000,
    description: 'iPad Air mỏng nhẹ, hỗ trợ Apple Pencil và bàn phím rời.',
    storageOptions: ['64GB', '256GB'],
    colorOptions: ['Xám', 'Xanh', 'Tím', 'Hồng'],
    stock: 20,
    rating: 4.7,
    reviewCount: 106,
  ),
  _product(
    id: 'samsung-galaxy-tab-s9',
    name: 'Samsung Galaxy Tab S9',
    brand: 'Samsung',
    categoryId: 'tablet',
    price: 19990000,
    oldPrice: 23990000,
    description: 'Tablet Android cao cấp, màn hình AMOLED và bút S Pen.',
    storageOptions: ['128GB', '256GB'],
    colorOptions: ['Xám', 'Be'],
    stock: 17,
    rating: 4.6,
    reviewCount: 92,
  ),
  _product(
    id: 'xiaomi-pad-6',
    name: 'Xiaomi Pad 6',
    brand: 'Xiaomi',
    categoryId: 'tablet',
    price: 9490000,
    oldPrice: 10990000,
    description: 'Máy tính bảng giá tốt với màn hình 144Hz và pin lớn.',
    storageOptions: ['128GB', '256GB'],
    colorOptions: ['Xám', 'Xanh', 'Vàng'],
    stock: 28,
    rating: 4.5,
    reviewCount: 77,
  ),
  _product(
    id: 'lenovo-tab-p12',
    name: 'Lenovo Tab P12',
    brand: 'Lenovo',
    categoryId: 'tablet',
    price: 5860000,
    oldPrice: 10400000,
    description: 'Tablet màn hình lớn, phù hợp học online và giải trí.',
    storageOptions: ['128GB'],
    colorOptions: ['Xám'],
    stock: 22,
    rating: 4.4,
    reviewCount: 54,
  ),
  _product(
    id: 'airpods-pro-2',
    name: 'AirPods Pro 2',
    brand: 'Apple',
    categoryId: 'headphone',
    price: 5990000,
    oldPrice: 6990000,
    description:
        'Tai nghe không dây có chống ồn chủ động và âm thanh không gian.',
    storageOptions: [],
    colorOptions: ['Trắng'],
    stock: 40,
    rating: 4.8,
    reviewCount: 230,
    isFeatured: true,
  ),
  _product(
    id: 'sony-wh-1000xm5',
    name: 'Sony WH-1000XM5',
    brand: 'Sony',
    categoryId: 'headphone',
    price: 5790000,
    oldPrice: 7990000,
    description:
        'Tai nghe chụp tai chống ồn cao cấp, pin lâu và âm thanh chi tiết.',
    storageOptions: [],
    colorOptions: ['Đen', 'Bạc'],
    stock: 25,
    rating: 4.7,
    reviewCount: 132,
  ),
  _product(
    id: 'jbl-tune-770nc',
    name: 'JBL Tune 770NC',
    brand: 'JBL',
    categoryId: 'headphone',
    price: 3490000,
    oldPrice: 3990000,
    description:
        'Tai nghe chống ồn phổ thông, âm bass mạnh và kết nối ổn định.',
    storageOptions: [],
    colorOptions: ['Đen', 'Xanh', 'Trắng'],
    stock: 36,
    rating: 4.4,
    reviewCount: 74,
  ),
  _product(
    id: 'samsung-galaxy-buds2-pro',
    name: 'Samsung Galaxy Buds2 Pro',
    brand: 'Samsung',
    categoryId: 'headphone',
    price: 4990000,
    oldPrice: 5990000,
    description: 'Tai nghe true wireless nhỏ gọn, chống ồn và âm thanh 24-bit.',
    storageOptions: [],
    colorOptions: ['Đen', 'Tím', 'Trắng'],
    stock: 32,
    rating: 4.5,
    reviewCount: 91,
  ),
  _product(
    id: 'logitech-g-pro-x',
    name: 'Logitech G Pro X',
    brand: 'Logitech',
    categoryId: 'headphone',
    price: 2990000,
    oldPrice: 3490000,
    description: 'Tai nghe gaming có micro rõ, đeo thoải mái khi chơi lâu.',
    storageOptions: [],
    colorOptions: ['Đen'],
    stock: 21,
    rating: 4.6,
    reviewCount: 83,
  ),
  _product(
    id: 'apple-watch-series-9',
    name: 'Apple Watch Series 9',
    brand: 'Apple',
    categoryId: 'watch',
    price: 10490000,
    oldPrice: 12990000,
    description: 'Đồng hồ thông minh theo dõi sức khỏe, hỗ trợ Double Tap.',
    storageOptions: ['41mm', '45mm'],
    colorOptions: ['Midnight', 'Starlight', 'Đỏ', 'Bạc'],
    stock: 24,
    rating: 4.8,
    reviewCount: 167,
    isFeatured: true,
  ),
  _product(
    id: 'apple-watch-ultra-2',
    name: 'Apple Watch Ultra 2',
    brand: 'Apple',
    categoryId: 'watch',
    price: 22990000,
    oldPrice: 25990000,
    description: 'Đồng hồ thể thao cao cấp, pin lâu và vỏ titan bền bỉ.',
    storageOptions: ['49mm'],
    colorOptions: ['Titan tự nhiên'],
    stock: 11,
    rating: 4.8,
    reviewCount: 98,
  ),
  _product(
    id: 'samsung-galaxy-watch-6',
    name: 'Samsung Galaxy Watch 6',
    brand: 'Samsung',
    categoryId: 'watch',
    price: 3190000,
    oldPrice: 6990000,
    description: 'Đồng hồ Wear OS, theo dõi giấc ngủ và sức khỏe hằng ngày.',
    storageOptions: ['40mm', '44mm'],
    colorOptions: ['Đen', 'Bạc', 'Vàng'],
    stock: 26,
    rating: 4.5,
    reviewCount: 85,
  ),
  _product(
    id: 'xiaomi-watch-s3',
    name: 'Xiaomi Watch S3',
    brand: 'Xiaomi',
    categoryId: 'watch',
    price: 3690000,
    oldPrice: 3990000,
    description: 'Đồng hồ thông minh giá tốt, nhiều mặt đồng hồ và pin lâu.',
    storageOptions: ['47mm'],
    colorOptions: ['Đen', 'Bạc'],
    stock: 31,
    rating: 4.4,
    reviewCount: 59,
  ),
  _product(
    id: 'garmin-forerunner-265',
    name: 'Garmin Forerunner 265',
    brand: 'Garmin',
    categoryId: 'watch',
    price: 9180000,
    oldPrice: 11690000,
    description: 'Đồng hồ chạy bộ GPS với màn hình AMOLED và chỉ số luyện tập.',
    storageOptions: ['42mm', '46mm'],
    colorOptions: ['Đen', 'Trắng', 'Xanh'],
    stock: 13,
    rating: 4.7,
    reviewCount: 71,
  ),
  _product(
    id: 'sac-apple-20w',
    name: 'Sạc Apple 20W',
    brand: 'Apple',
    categoryId: 'accessory',
    price: 520000,
    oldPrice: 890000,
    description: 'Củ sạc nhanh USB-C 20W chính hãng cho iPhone và iPad.',
    storageOptions: [],
    colorOptions: ['Trắng'],
    stock: 80,
    rating: 4.6,
    reviewCount: 220,
  ),
  _product(
    id: 'cap-usb-c-to-lightning',
    name: 'Cáp USB-C to Lightning',
    brand: 'Apple',
    categoryId: 'accessory',
    price: 520000,
    oldPrice: 590000,
    description: 'Cáp sạc và truyền dữ liệu USB-C to Lightning dài 1m.',
    storageOptions: ['1m', '2m'],
    colorOptions: ['Trắng'],
    stock: 95,
    rating: 4.5,
    reviewCount: 184,
  ),
  _product(
    id: 'logitech-mx-master-3s',
    name: 'Chuột Logitech MX Master 3S',
    brand: 'Logitech',
    categoryId: 'accessory',
    price: 2290000,
    oldPrice: 2690000,
    description: 'Chuột không dây cao cấp, cuộn êm và làm việc đa thiết bị.',
    storageOptions: [],
    colorOptions: ['Đen', 'Xám'],
    stock: 34,
    rating: 4.8,
    reviewCount: 143,
  ),
  _product(
    id: 'keychron-k2',
    name: 'Bàn phím Keychron K2',
    brand: 'Keychron',
    categoryId: 'accessory',
    price: 1490000,
    oldPrice: 1790000,
    description:
        'Bàn phím cơ không dây layout gọn, phù hợp làm việc và học tập.',
    storageOptions: ['Brown switch', 'Red switch', 'Blue switch'],
    colorOptions: ['Đen', 'Xám'],
    stock: 27,
    rating: 4.7,
    reviewCount: 118,
  ),
  _product(
    id: 'anker-powercore-20000mah',
    name: 'Pin dự phòng Anker 20000mAh',
    brand: 'Anker',
    categoryId: 'accessory',
    price: 830000,
    oldPrice: 1000000,
    description:
        'Pin dự phòng dung lượng lớn, sạc được nhiều lần cho điện thoại.',
    storageOptions: ['20000mAh'],
    colorOptions: ['Đen'],
    stock: 60,
    rating: 4.6,
    reviewCount: 156,
  ),
];

const Map<String, List<String>> productImageLinks = {
  // Phones
  'iphone-15-pro-max': [
    'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-1-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-3-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-4-1.jpg',
  ],
  'iphone-15': [
    'https://cdn.tgdd.vn/Products/Images/42/281570/iphone-15-1-3.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/281570/iphone-15-128gb-xanh-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/281570/iphone-15-128gb-xanh-3.jpg',
  ],
  'samsung-galaxy-s24-ultra': [
    'https://cdn.tgdd.vn/Products/Images/42/307174/samsung-galaxy-s24-ultra-xam-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/307174/samsung-galaxy-s24-ultra-xam-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/307174/samsung-galaxy-s24-ultra-xam-3.jpg',
  ],
  'xiaomi-14': [
    'https://cdn.tgdd.vn/Products/Images/42/322526/xiaomi-14-trang-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/322526/xiaomi-14-trang-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/322526/xiaomi-14-trang-3.jpg',
  ],
  'oppo-reno-11': [
    'https://cdn.tgdd.vn/Products/Images/42/314209/oppo-reno-11-xanh-1-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/314209/oppo-reno-11-xanh-2-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/42/314209/oppo-reno-11-xanh-3-1.jpg',
  ],

  // Laptops
  'macbook-air-m2': [
    'https://cdn.tgdd.vn/Products/Images/44/282827/apple-macbook-air-m2-2022-01.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/282827/apple-macbook-air-m2-2022-02.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/282827/apple-macbook-air-m2-2022-03.jpg',
  ],
  'macbook-pro-m3': [
    'https://cdn.tgdd.vn/Products/Images/44/322359/apple-macbook-pro-14-inch-m3-pro-2023-silver-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/322359/apple-macbook-pro-14-inch-m3-pro-2023-silver-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/322359/apple-macbook-pro-14-inch-m3-pro-2023-silver-3.jpg',
  ],
  'dell-xps-13': [
    'https://cdn.tgdd.vn/Products/Images/44/269554/dell-xps-13-9310-i5-70273578-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/269554/dell-xps-13-9310-i5-70273578-xy-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/269554/dell-xps-13-9310-i5-70273578-xy-3.jpg',
  ],
  'asus-rog-zephyrus-g14': [
    'https://cdn.tgdd.vn/Products/Images/44/251418/asus-rog-zephyrus-gaming-g14-ga401qec-r9-k2064t-1-org.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/251418/asus-rog-zephyrus-gaming-g14-ga401qec-r9-k2064t-2-org.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/251418/asus-rog-zephyrus-gaming-g14-ga401qec-r9-k2064t-3-org.jpg',
  ],
  'lenovo-thinkpad-x1-carbon': [
    'https://cdn.tgdd.vn/Products/Images/44/292926/lenovo-thinkpad-x1-carbon-gen-10-i7-21cb00a8vn-1-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/292926/lenovo-thinkpad-x1-carbon-gen-10-i7-21cb00a8vn-2-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/44/292926/lenovo-thinkpad-x1-carbon-gen-10-i7-21cb00a8vn-3-1.jpg',
  ],

  // Tablets
  'ipad-pro-m4': [
    'https://cdn.tgdd.vn/Products/Images/522/325534/ipad-pro-13-inch-m4-lte-black-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/325534/ipad-pro-13-inch-m4-lte-black-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/325534/ipad-pro-13-inch-m4-lte-black-3.jpg',
  ],
  'ipad-air-5': [
    'https://cdn.tgdd.vn/Products/Images/522/274154/ipad-air-5-m1-trang-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/274154/ipad-air-5-m1-trang-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/274154/ipad-air-5-m1-trang-3.jpg',
  ],
  'samsung-galaxy-tab-s9': [
    'https://cdn.tgdd.vn/Products/Images/522/303299/samsung-galaxy-tab-s9-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/303299/samsung-galaxy-tab-s9-wifi-xam-128gb-3.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/303299/samsung-galaxy-tab-s9-wifi-xam-128gb-4.jpg',
  ],
  'xiaomi-pad-6': [
    'https://cdn.tgdd.vn/Products/Images/522/309848/xiaomi-pad-6-xanh-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/309848/xiaomi-pad-6-blue-3.jpg',
    'https://cdn.tgdd.vn/Products/Images/522/309848/xiaomi-pad-6-blue-4.jpg',
  ],
  'lenovo-tab-p12': [
    'https://fdn2.gsmarena.com/vv/pics/lenovo/lenovo-tab-p12-1.jpg',
    'https://fdn2.gsmarena.com/vv/pics/lenovo/lenovo-tab-p12-2.jpg',
    'https://fdn2.gsmarena.com/vv/pics/lenovo/lenovo-tab-p12-3.jpg',
  ],

  // Headphones
  'airpods-pro-2': [
    'https://cdn.tgdd.vn/Products/Images/54/289781/airpods-pro-2nd-generation-0.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/289781/airpods-pro-2nd-generation-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/289781/airpods-pro-2nd-generation-1.jpg',
  ],
  'sony-wh-1000xm5': [
    'https://cdn.tgdd.vn/Products/Images/54/313692/tai-nghe-bluetooth-chup-tai-sony-wh1000xm5-den-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/313692/tai-nghe-bluetooth-chup-tai-sony-wh1000xm5-den-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/313692/tai-nghe-bluetooth-chup-tai-sony-wh1000xm5-den-3.jpg',
  ],
  'jbl-tune-770nc': [
    'https://vn.jbl.com/dw/image/v2/AAUJ_PRD/on/demandware.static/-/Sites-masterCatalog_Harman/default/dwdf44b20f/JBL_TUNE_770NC_FOLD_REGULAR_BLACK_41791_x1.png?sfrm=png&sw=537',
    'https://vn.jbl.com/dw/image/v2/AAUJ_PRD/on/demandware.static/-/Sites-masterCatalog_Harman/default/dwdf44b20f/JBL_TUNE_770NC_FOLD_REGULAR_BLACK_41791_x1.png?sfrm=png&sw=800',
  ],
  'samsung-galaxy-buds2-pro': [
    'https://cdn.tgdd.vn/Products/Images/54/286046/tai-nghe-bluetooth-true-wireless-galaxy-buds2-pro-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/286046/tai-nghe-bluetooth-true-wireless-galaxy-buds2-pro-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/54/286046/tai-nghe-bluetooth-true-wireless-galaxy-buds2-pro-4.jpg',
  ],
  'logitech-g-pro-x': [
    'https://www.pngkey.com/png/detail/218-2182739_learn-more-logitech-g-pro-gaming-headset.png',
  ],

  // Smart watches
  'apple-watch-series-9': [
    'https://cdn.tgdd.vn/Products/Images/7077/314708/apple-watch-s9-45mm-vien-nhom-day-silicone-trang-starlight-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/314708/apple-watch-s9-45mm-vien-nhom-day-silicone-trang-starlight-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/314708/apple-watch-s9-45mm-vien-nhom-day-silicone-trang-starlight-3.jpg',
  ],
  'apple-watch-ultra-2': [
    'https://cdn.tgdd.vn/Products/Images/7077/314714/apple-watch-ultra-lte-49mm-vien-titanium-day-trail-size-m-l-den-101.jpg',
    'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/7077/314714/apple-watch-ultra-2-lte-49mm-vien-titanium-day-trail-size-m-l-638641720552155367.jpg',
    'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/7077/314714/apple-watch-ultra-2-lte-49mm-vien-titanium-day-trail-size-m-l-1-638641720545473864.jpg',
  ],
  'samsung-galaxy-watch-6': [
    'https://cdn.tgdd.vn/Products/Images/7077/310849/samsung-galaxy-watch6-40-mm-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/310849/samsung-galaxy-watch6-40-mm-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/310849/samsung-galaxy-watch6-40-mm-3.jpg',
  ],
  'xiaomi-watch-s3': [
    'https://cdn.tgdd.vn/Products/Images/7077/321817/xiaomi-watch-s-3-den-2-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/321817/xiaomi-watch-s-3-den-1-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/321817/xiaomi-watch-s-3-den-3-1.jpg',
  ],
  'garmin-forerunner-265': [
    'https://cdn.tgdd.vn/Products/Images/7077/305882/garmin-forerunner-265-den-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/305882/garmin-forerunner-265-den-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/7077/305882/garmin-forerunner-265-den-3.jpg',
  ],

  // Accessories
  'sac-apple-20w': [
    'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-1-org.jpg',
    'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-2-org.jpg',
    'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-3-org.jpg',
  ],
  'cap-usb-c-to-lightning': [
    'https://cdn.tgdd.vn/Products/Images/58/259283/cap-type-c-lightning-1m-apple-mm0a3-trang-1-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/58/259283/cap-type-c-lightning-1m-apple-mm0a3-trang-2.jpeg',
    'https://cdn.tgdd.vn/Products/Images/58/259283/cap-type-c-lightning-1m-apple-mm0a3-trang-3-1.jpg',
  ],
  'logitech-mx-master-3s': [
    'https://cdn.tgdd.vn/Products/Images/86/326659/chuot-bluetooth-silent-logitech-mx-master-3s-den-1.jpg',
    'https://cdn.tgdd.vn/Products/Images/86/326659/chuot-bluetooth-silent-logitech-mx-master-3s-den-3.jpg',
    'https://cdn.tgdd.vn/Products/Images/86/326659/chuot-bluetooth-silent-logitech-mx-master-3s-den-2.jpg',
  ],
  'keychron-k2': [
    'https://www.keychron.com/cdn/shop/products/keychron-k2-keyboard-carrying-case-plastic_x250%402x.jpg?v=1608634266',
    'https://www.keychron.com/cdn/shop/products/keychron-k4-keyboard-carrying-case-for-alu-frame-version_x250%402x.jpg?v=1608634271',
  ],
  'anker-powercore-20000mah': [
    'https://cdn.tgdd.vn/Products/Images/57/253589/pin-polymer-20000mah-type-c-pd-20w-anker-a1287-3.jpg',
    'https://cdn.tgdd.vn/Products/Images/57/253589/pin-polymer-20000mah-type-c-pd-20w-anker-a1287-2.jpg',
    'https://cdn.tgdd.vn/Products/Images/57/253589/pin-polymer-20000mah-type-c-pd-20w-anker-a1287-4.jpg',
  ],
};

Map<String, dynamic> _product({
  required String id,
  required String name,
  required String brand,
  required String categoryId,
  required int price,
  required int oldPrice,
  required String description,
  required List<String> storageOptions,
  required List<String> colorOptions,
  required int stock,
  required double rating,
  required int reviewCount,
  bool isFeatured = false,
}) {
  final imageUrls = productImageLinks[id] ??
      [
        'https://picsum.photos/seed/$id/800/800',
      ];
  final imageUrl = imageUrls.first;
  final variants = _buildVariants(
    productId: id,
    basePrice: price,
    oldPrice: oldPrice,
    totalStock: stock,
    storageOptions: storageOptions,
    colorOptions: colorOptions,
    imageUrls: imageUrls,
  );
  final prices = variants.map((variant) => variant['price'] as int).toList();
  final totalStock = variants.fold<int>(
    0,
    (total, variant) => total + (variant['stock'] as int),
  );

  return {
    'id': id,
    'name': name,
    'brand': brand,
    'categoryId': categoryId,
    'description': description,
    'imageUrl': imageUrl,
    'images': imageUrls,
    'minPrice': prices.reduce((a, b) => a < b ? a : b),
    'maxPrice': prices.reduce((a, b) => a > b ? a : b),
    'totalStock': totalStock,
    'rating': rating,
    'reviewCount': reviewCount,
    'isFeatured': isFeatured,
    'isActive': true,
    'createdAt': _now,
    'updatedAt': _now,
    '_variants': variants,
  };
}

List<Map<String, dynamic>> _buildVariants({
  required String productId,
  required int basePrice,
  required int oldPrice,
  required int totalStock,
  required List<String> storageOptions,
  required List<String> colorOptions,
  required List<String> imageUrls,
}) {
  final storages = storageOptions.isEmpty ? ['Mặc định'] : storageOptions;
  final colors = colorOptions.isEmpty ? ['Mặc định'] : colorOptions;
  final combinations = <Map<String, String>>[];

  for (final storage in storages.take(4)) {
    combinations.add({'storage': storage, 'color': colors.first});
  }

  for (final color in colors.skip(1)) {
    if (combinations.length >= 4) break;
    combinations.add({'storage': storages.first, 'color': color});
  }

  final stockPerVariant =
      (totalStock / combinations.length).ceil().clamp(1, totalStock).toInt();
  final priceStep = _priceStep(basePrice);

  return combinations.asMap().entries.map((entry) {
    final index = entry.key;
    final combination = entry.value;
    final storage = combination['storage'] ?? 'Mặc định';
    final color = combination['color'] ?? 'Mặc định';
    final priceLevel = index < storages.length ? index : 0;
    final variantPrice = basePrice + priceLevel * priceStep;
    final variantOldPrice =
        oldPrice > 0 ? oldPrice + priceLevel * priceStep : 0;

    return {
      'id': 'v${index + 1}',
      'productId': productId,
      'storage': storage,
      'color': color,
      'price': variantPrice,
      'oldPrice': variantOldPrice,
      'stock': index == combinations.length - 1
          ? (totalStock - stockPerVariant * index).clamp(1, totalStock)
          : stockPerVariant,
      'sku': '${productId.toUpperCase()}-V${index + 1}',
      'imageUrl': imageUrls[index % imageUrls.length],
      'isActive': true,
      'createdAt': _now,
      'updatedAt': _now,
    };
  }).toList();
}

int _priceStep(int price) {
  if (price >= 20000000) return 3000000;
  if (price >= 5000000) return 1000000;
  if (price >= 1000000) return 300000;
  return 50000;
}
