import 'product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  // Convert from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '', //nếu có id thì dùng id nếu không có thì dùng chuỗi rỗng
      product: Product.fromJson(json['product']), // lấy thông tin sản phẩm từ json
      quantity: json['quantity'] ?? 1, // Nếu không có mặc định = 1
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };// dùng để upload dữ liệu lên server hoặc lưu vào local storage
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    ); // copyWith = clone object + thay đổi 1 vài field
    // dùng để tạo một bản sao của CartItem hiện tại với các trường có thể được thay đổi
    // ví dụ: cartItem.copyWith(quantity: 5) sẽ tạo một bản sao của cartItem với số lượng được cập nhật thành 5
  }

  @override
  String toString() =>
      'CartItem(id: $id, product: ${product.name}, quantity: $quantity)';
}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  int get itemCount => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem item) {
    final existingIndex =
        items.indexWhere((i) => i.product.id == item.product.id);
    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex]
          .copyWith(quantity: items[existingIndex].quantity + item.quantity);
    } else {
      items.add(item);
    }
  }

  void removeItem(String cartItemId) {
    items.removeWhere((item) => item.id == cartItemId);
  }

  void updateQuantity(String cartItemId, int quantity) {
    final index = items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(cartItemId);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
    }
  }

  void clear() {
    items.clear();
  }

  @override
  String toString() => 'Cart(itemCount: $itemCount, totalPrice: $totalPrice)';
}
