import 'package:intl/intl.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String productId; // mã sản phẩm
  final String productName; //tên sản phẩm
  final double price; // giá sản phẩm
  final int quantity; // số lượng sản phẩm trong đơn hàng
  final String productImage; // URL hình ảnh sản phẩm

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.productImage,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // chấp nhận cả int và double, nếu không có giá trị thì mặc định là 0.0
      quantity: json['quantity'] ?? 0,
      productImage: json['productImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'productImage': productImage,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String? phone;
  final DateTime createdAt;
  final DateTime? deliveredAt;// Ngày giao hàng (có thể chưa có)
  final String? trackingNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.phone,
    required this.createdAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  int get itemCount => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);  // cộng dồn số lượng của tất cả các item trong đơn hàng

  String get formattedDate => DateFormat('dd/MM/yyyy').format(createdAt);

  String get formattedTotalAmount {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(totalAmount);
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đã gửi hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: json['items'] != null
          ? List<OrderItem>.from(
              json['items'].map((item) => OrderItem.fromJson(item)))
          : [],// nếu không có items thì mặc định là một list rỗng
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
          (e) => e.toString() == 'OrderStatus.${json['status']}',
          orElse: () => OrderStatus.pending), // nếu không có status hoặc không khớp với bất kỳ giá trị nào trong enum thì mặc định là pending
      shippingAddress: json['shippingAddress'] ?? '',
      phone: json['phone'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),// nếu không có createdAt thì mặc định là thời điểm hiện tại
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,// nếu không có deliveredAt thì mặc định là null
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }

  @override
  String toString() => 'Order(id: $id, status: ${status.name}, items: $itemCount)';
}
