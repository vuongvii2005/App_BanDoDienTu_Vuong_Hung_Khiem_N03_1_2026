// for assginment
import 'order_model.dart';
class ListOrder {
  final List<Order> _orders = [];
  // tạo mới một đơn hàng và thêm vào danh sách
  bool addOrder(Order order) {
    if (_orders.any((o) => o.id == order.id)) {
      // nếu đã tồn tại đơn hàng với cùng ID thì không thêm và trả về false
      return false;
    }
    _orders.add(order);
    return true;
  }

  // trả về một bản sao của danh sách đơn hàng hiện tại để tránh bị sửa đổi trực tiếp từ bên ngoài
  List<Order> getAllOrders() {
    return List.unmodifiable(_orders);
  }

  // Get a specific order by its ID
  // trả về đơn hàng nếu tìm thấy, nếu không tìm thấy trả về null
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update an existing order
  // trả về true nếu đơn hàng được cập nhật thành công, false nếu không tìm thấy đơn hàng
  bool updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index == -1) {
      return false;
    }
    _orders[index] = updatedOrder;
    return true;
  }
  // Delete an order by its ID
  //trả về true nếu đơn hàng được xóa thành công, false nếu không tìm thấy đơn hàng
  bool deleteOrder(String id) {
    final initialLength = _orders.length;
    _orders.removeWhere((order) => order.id == id);
    return _orders.length < initialLength;
  }

  // Get the total number of orders
  int get totalOrders => _orders.length;

  // Check if the list is empty
  bool get isEmpty => _orders.isEmpty;

  // Get orders by user ID
  List<Order> getOrdersByUserId(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // delete
  void clearAll() {
    _orders.clear();
  }
}
