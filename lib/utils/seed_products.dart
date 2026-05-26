import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app_new/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  await seedCategories(firestore);
  await seedProducts(firestore);

  print('Seed products completed.');
}

Future<void> seedCategories(FirebaseFirestore firestore) async {
  final categories = <String, String>{
    'phone': 'Điện thoại',
    'laptop': 'Máy tính xách tay',
    'tablet': 'Máy tính bảng',
    'accessory': 'Phụ kiện',
  };

  for (final category in categories.entries) {
    await firestore.collection('categories').doc(category.key).set({
      'name': category.value,
    });
  }
}

Future<void> seedProducts(FirebaseFirestore firestore) async {
  final products = <String, Map<String, dynamic>>{
    'iphone-15': {
      'name': 'iPhone 15',
      'description': 'Smartphone Apple với màn hình Super Retina XDR.',
      'price': 799,
      'categoryId': 'phone',
      'image': 'https://picsum.photos/seed/iphone15/600/400',
      'stock': 20,
      'rating': 4.8,
      'reviewCount': 120,
    },
    'samsung-galaxy-s24': {
      'name': 'Samsung Galaxy S24',
      'description': 'Điện thoại Android cao cấp với camera sắc nét.',
      'price': 749,
      'categoryId': 'phone',
      'image': 'https://picsum.photos/seed/galaxys24/600/400',
      'stock': 18,
      'rating': 4.7,
      'reviewCount': 95,
    },
    'google-pixel-8': {
      'name': 'Google Pixel 8',
      'description': 'Smartphone Android gọn nhẹ, chụp ảnh đẹp.',
      'price': 699,
      'categoryId': 'phone',
      'image': 'https://picsum.photos/seed/pixel8/600/400',
      'stock': 15,
      'rating': 4.6,
      'reviewCount': 88,
    },
    'macbook-air-m3': {
      'name': 'MacBook Air M3',
      'description': 'Laptop mỏng nhẹ, pin lâu, phù hợp học tập và làm việc.',
      'price': 1099,
      'categoryId': 'laptop',
      'image': 'https://picsum.photos/seed/macbookairm3/600/400',
      'stock': 10,
      'rating': 4.9,
      'reviewCount': 140,
    },
    'dell-xps-13': {
      'name': 'Dell XPS 13',
      'description': 'Laptop Windows cao cấp với thiết kế nhỏ gọn.',
      'price': 999,
      'categoryId': 'laptop',
      'image': 'https://picsum.photos/seed/dellxps13/600/400',
      'stock': 8,
      'rating': 4.5,
      'reviewCount': 73,
    },
    'asus-vivobook-15': {
      'name': 'ASUS VivoBook 15',
      'description': 'Laptop phổ thông có màn hình lớn và hiệu năng ổn định.',
      'price': 599,
      'categoryId': 'laptop',
      'image': 'https://picsum.photos/seed/vivobook15/600/400',
      'stock': 14,
      'rating': 4.4,
      'reviewCount': 61,
    },
    'ipad-air': {
      'name': 'iPad Air',
      'description': 'Máy tính bảng màn hình đẹp, hỗ trợ Apple Pencil.',
      'price': 599,
      'categoryId': 'tablet',
      'image': 'https://picsum.photos/seed/ipadair/600/400',
      'stock': 16,
      'rating': 4.8,
      'reviewCount': 112,
    },
    'samsung-galaxy-tab-s9': {
      'name': 'Samsung Galaxy Tab S9',
      'description': 'Tablet Android cao cấp với bút S Pen đi kèm.',
      'price': 699,
      'categoryId': 'tablet',
      'image': 'https://picsum.photos/seed/tabs9/600/400',
      'stock': 11,
      'rating': 4.6,
      'reviewCount': 79,
    },
    'sony-wh-1000xm5': {
      'name': 'Sony WH-1000XM5',
      'description': 'Tai nghe chống ồn cao cấp, âm thanh chi tiết.',
      'price': 399,
      'categoryId': 'accessory',
      'image': 'https://picsum.photos/seed/sonyxm5/600/400',
      'stock': 25,
      'rating': 4.7,
      'reviewCount': 130,
    },
    'anker-powercore-20k': {
      'name': 'Anker PowerCore 20000',
      'description': 'Pin sạc dự phòng dung lượng lớn cho điện thoại và tablet.',
      'price': 49,
      'categoryId': 'accessory',
      'image': 'https://picsum.photos/seed/ankerpowercore/600/400',
      'stock': 40,
      'rating': 4.5,
      'reviewCount': 54,
    },
  };

  for (final product in products.entries) {
    await firestore.collection('products').doc(product.key).set(product.value);
  }
}
