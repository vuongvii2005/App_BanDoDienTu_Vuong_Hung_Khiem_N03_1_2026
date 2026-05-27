import 'product_model.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  String selectedStorage;
  String selectedColor;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedStorage = '',
    this.selectedColor = '',
  });

  double get totalPrice => product.price * quantity;
}
