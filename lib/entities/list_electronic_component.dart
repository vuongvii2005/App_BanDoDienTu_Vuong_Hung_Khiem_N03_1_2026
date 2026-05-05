import 'electronic_component.dart';

class ListElectronicComponent {
  // Biến danh sách các ElectronicComponent
  List<ElectronicComponent> components = [];

  // Constructor với dữ liệu mẫu để khởi tạo
  ListElectronicComponent() {
    // Thêm một số linh kiện mẫu
    components.addAll([
      ElectronicComponent(
        id: '1',
        name: 'Resistor 10kΩ',
        category: 'Resistor',
        price: 0.5,
        quantity: 100,
        manufacturer: 'ABC Electronics',
        voltage: 5.0,
        power: 0.25,
        description: 'A standard 10kΩ resistor.',
      ),
      ElectronicComponent(
        id: '2',
        name: 'Capacitor 10μF',
        category: 'Capacitor',
        price: 1.0,
        quantity: 50,
        manufacturer: 'XYZ Components',
        voltage: 16.0,
        power: 0.0,
        description: 'A 10μF electrolytic capacitor.',
      ),
    ]);
  }

  // Create: Tạo và thêm một bản ghi ElectronicComponent mới
  void create(ElectronicComponent component) {
    // Kiểm tra id duy nhất
    bool idExists = components.any((comp) => comp.id == component.id);
    if (!idExists) {
      components.add(component);
    } else {
      throw Exception('ID đã tồn tại: ${component.id}');
    }
  }

  // Read: Đọc tất cả bản ghi trong danh sách
  List<ElectronicComponent> readAll() {
    return List.from(components); // Trả về bản sao để tránh thay đổi trực tiếp
  }

  // Edit: Sửa bản ghi có id cụ thể
  void edit(String id, ElectronicComponent updatedComponent) {
    int index = components.indexWhere((component) => component.id == id);
    if (index != -1) {
      components[index] = updatedComponent;
    } else {
      throw Exception('Không tìm thấy bản ghi với ID: $id');
    }
  }
}
