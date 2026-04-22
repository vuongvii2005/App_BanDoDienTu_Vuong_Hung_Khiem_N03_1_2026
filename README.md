# shop_app_new

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Bài 3: ElectronicComponent
File: `lib/electronic_component.dart`

**Biến:** id, name, category, price, quantity, manufacturer, voltage, power, description

**Phương thức:**
- `addStock(amount)` - Thêm hàng vào kho
- `removeStock(amount)` - Lấy hàng từ kho
- `updatePrice(newPrice)` - Cập nhật giá
- `calculateTotalPrice(amount)` - Tính tổng tiền
- `getInfo()` - Lấy thông tin chi tiết

---

## Bài 4: ListElectronicComponent (CRUD)
File: `lib/list_electronic_component.dart`

**Biến:**
- `components: List<ElectronicComponent>` - Danh sách linh kiện

**Phương thức CRUD:**
- `create(component)` - Thêm bản ghi mới
- `readAll()` - Đọc tất cả bản ghi
- `edit(id, updatedComponent)` - Sửa bản ghi có id cụ thể

---

## Thành Viên Nhóm
- 23016891 - Vi Hùng Vương
- 23010092 - Nguyễn Anh Khiêm
- 23010103 - Nguyễn Quang Hưng
