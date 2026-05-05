class ElectronicComponent {
  String id;
  String name;
  String category;
  double price;
  int quantity;
  String manufacturer;
  double voltage;
  double power;
  String description;

  ElectronicComponent({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.manufacturer,
    required this.voltage,
    required this.power,
    required this.description,
  });

  void addStock(int amount) {
    quantity += amount;
  }

  void removeStock(int amount) {
    if (quantity >= amount) {
      quantity -= amount;
    }
  }

  void updatePrice(double newPrice) {
    price = newPrice;
  }

  double calculateTotalPrice(int amount) {
    return price * amount;
  }

  String getInfo() {
    return "ID: $id\nName: $name\nCategory: $category\nPrice: $price\nQuantity: $quantity";
  }
}
