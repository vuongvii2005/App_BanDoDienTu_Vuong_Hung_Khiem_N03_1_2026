# Lập trình cho thiết bị di động-1-3-25(N03)
# App_BanDoDienTu_Vuong_Hung_Khiem_N03_1_2026
# Thành viên nhóm
- Vi Hùng Vương 23016891
- Nguyễn Anh Khiêm 23010092
- Nguyễn Quang Hưng 23010103

# bài thực hành 1
##  1. tạo repo nhóm
<img width="1919" height="926" alt="image" src="https://github.com/user-attachments/assets/c50f130f-88de-4bc9-bade-e5fee4c51bb9" />
## 2. Add thành viên vào Repo nhóm
<img width="1917" height="908" alt="image" src="https://github.com/user-attachments/assets/3466ca28-0372-4a49-b6c2-7dd044c96aa1" />
## 3. Tạo một framework Flutter cho nhóm để làm việc từ buổi ngày 8/4/2026 đến hết môn học.
<img width="1919" height="1021" alt="image" src="https://github.com/user-attachments/assets/2cfbce8c-2b5c-49de-8544-32945ee2c8e4" />
## 4. Thay đổi code trên repo 
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/606b0676-29e2-434f-9137-eda3ad32f65e" />

# bài thực hành 2
# bài thực hành 3
Câu 1:

Static là một phương thức dùng để khai báo thuộc tính (biến) hoặc phương thức(hàm) thuộc về class, không thuộc về object ( ý là không cần tạo obj vẫn dùng được và dùng trực tiếp qua tên class). Điều này có nghĩa là các thành phần được khai báo bằng static sẽ được chia set chung cho tất cả các đối tượng của lớp đó.

Cách sử dụng :

Class demo{

               String ten = “Vuong”;

               Static int tuoi = 21;

}

Int main (){

               Var t = new Demo();

               Print(t.ten); // cần obj

               Print(demo.tuoi); // không cần obj

}

Static dùng khi làm các hàm hỗ trợ như tính toán hoặc các dữ liệu dùng chung

Ưu điểm của hàm static là:

không cần tạo obj nên tiết kiệm bộ nhớ.
Truy cập nhanh, rõ ràng (className.tenThanhPhan là ra)
Dùng tốt cho các dữ liệu dùng chung.
Phù hợp cho các hàm tính toán hoặc hỗ trợ.

Nhược điểm của static là:

Lạm dụng khiến code khó mở rộng do không truy cập được biến non-static, không dùng được this, test khó trong vài trường hợp do không cần tạo obj

Câu 2:

// for assignment

class DataPrinter<T> {
  T obj;
  DataPrinter(this.obj);
  void printData() {

    print(obj);

  }

}

void main() {

  var student = [

    {'studentID': 's123456', 'fullname': 'Nguyen Thi B'},

    {'studentID': 's345672', 'fullname': 'Nguyen Van D'},

    {'studentID': 's923333', 'fullname': 'Tran Thi  Van'},

  ];




  var printer = DataPrinter(student);

  printer.printData();

}

Câu 3:file order_models.dart

Lớp Order được xây dựng để quản lý thông tin đơn hàng trong hệ thống bán hàng. Mỗi đơn hàng bao gồm các thuộc tính như mã đơn hàng (id), mã người dùng (userId), danh sách sản phẩm (items), tổng tiền (totalAmount), trạng thái đơn hàng (status), địa chỉ giao hàng và thời gian tạo đơn.

Ngoài ra, lớp còn cung cấp các phương thức như tính tổng số lượng sản phẩm, định dạng ngày tháng và số tiền, cũng như chuyển đổi dữ liệu giữa dạng object và JSON để phục vụ việc lưu trữ và trao đổi dữ liệu với hệ thống backend.

Câu 4:file list_order.dart

Lớp ListOrder được xây dựng để quản lý danh sách các đơn hàng trong hệ thống. Lớp này sử dụng một danh sách (List<Order>) để lưu trữ dữ liệu và cung cấp các chức năng theo mô hình CRUD.

Cụ thể, lớp hỗ trợ thêm đơn hàng mới (Create), lấy danh sách hoặc tìm kiếm theo id (Read), cập nhật thông tin đơn hàng (Update) và xóa đơn hàng (Delete). Ngoài ra, lớp còn có các phương thức bổ sung như lọc đơn hàng theo người dùng hoặc trạng thái, giúp việc quản lý dữ liệu trở nên linh hoạt và hiệu quả hơn.

câu 5
https://github.com/vuongvii2005/App_BanDoDienTu_Vuong_Hung_Khiem_N03_1_2026/blob/vuong/README.md
https://github.com/vuongvii2005/App_BanDoDienTu_Vuong_Hung_Khiem_N03_1_2026/tree/vuong

bài kiểm tra giữa kỳ
Vi Hùng Vương
làm phần content

Cấu trúc thư mục
Cấu trúc thư mục dự án hiện tại
lib/                              # Source code chính của ứng dụng Flutter
│
├── main.dart                     # Điểm khởi động app, init Firebase, Provider, Theme, Routes
├── firebase_options.dart         # Cấu hình Firebase cho các nền tảng
│
├── config/                       # Cấu hình chung của app
│   ├── app_routes.dart           # Quản lý route, điều hướng giữa các màn hình
│   └── app_theme.dart            # Quản lý theme, màu sắc, style giao diện
│
├── database/                     # Dữ liệu mẫu và seed dữ liệu
│   ├── mock_data.dart            # Dữ liệu giả/local để test giao diện
│   └── seed_firestore.dart       # Đẩy dữ liệu mẫu lên Firestore
│
├── models/                       # Data models - cấu trúc dữ liệu
│   ├── user_model.dart           # Model người dùng
│   ├── product_model.dart        # Model sản phẩm
│   ├── category_model.dart       # Model danh mục
│   ├── cart_item_model.dart      # Model sản phẩm trong giỏ hàng
│   ├── order_model.dart          # Model đơn hàng
│   └── review_model.dart         # Model đánh giá sản phẩm
│
├── services/                     # Xử lý Firebase/Auth/Firestore
│   ├── auth_service.dart         # Đăng nhập, đăng ký, đăng xuất
│   ├── user_service.dart         # Lấy/cập nhật thông tin user
│   ├── product_service.dart      # Lấy/thêm/sửa/xóa sản phẩm
│   ├── category_service.dart     # Lấy danh mục sản phẩm
│   ├── cart_service.dart         # Thêm/xóa/cập nhật giỏ hàng
│   ├── order_service.dart        # Tạo đơn hàng, lấy lịch sử đơn
│   └── review_service.dart       # Xử lý đánh giá sản phẩm
│
├── providers/                    # State management - quản lý trạng thái app
│   ├── auth_provider.dart        # State đăng nhập, user hiện tại, role user/admin
│   ├── user_provider.dart        # State thông tin cá nhân user
│   ├── product_provider.dart     # State sản phẩm, lọc, tìm kiếm
│   ├── category_provider.dart    # State danh mục
│   ├── cart_provider.dart        # State giỏ hàng, tổng tiền
│   ├── order_provider.dart       # State đơn hàng, lịch sử đơn hàng
│   └── search_provider.dart      # State tìm kiếm sản phẩm
│
├── screens/                      # Các màn hình chính của app
│   ├── home_screen.dart          # Trang chủ, bottom navigation, tab cá nhân
│   ├── product_list_screen.dart  # Danh sách sản phẩm
│   ├── product_detail_screen.dart # Chi tiết sản phẩm
│   ├── search_screen.dart        # Tìm kiếm sản phẩm
│   ├── cart_screen.dart          # Giỏ hàng
│   ├── checkout_screen.dart      # Nhập thông tin giao hàng
│   ├── payment_method_screen.dart # Chọn phương thức thanh toán
│   ├── order_confirm_screen.dart # Xác nhận đơn hàng
│   ├── order_success_screen.dart # Đặt hàng thành công
│   ├── order_history_screen.dart # Lịch sử đơn hàng
│   ├── order_detail_screen.dart  # Chi tiết đơn hàng
│   │
│   ├── auth/                     # Màn hình xác thực
│   │   ├── login_screen.dart     # Đăng nhập
│   │   └── register_screen.dart  # Đăng ký
│   │
│   └── admin/                    # Màn hình quản trị
│       └── admin_dashboard_screen.dart # Trang quản trị cơ bản
│
├── widgets/                      # Component giao diện dùng lại
│   ├── common/                   # Widget dùng chung
│   │   ├── bottom_nav_bar.dart   # Thanh điều hướng dưới
│   │   ├── loading_widget.dart   # Loading
│   │   └── primary_button.dart   # Nút chính
│   │
│   ├── home/                     # Widget trang chủ
│   │   ├── banner_slider.dart    # Banner trượt
│   │   ├── category_section.dart # Khu vực danh mục
│   │   └── featured_products.dart # Sản phẩm nổi bật
│   │
│   ├── product/                  # Widget sản phẩm
│   │   ├── product_card.dart     # Thẻ sản phẩm
│   │   ├── quantity_selector.dart # Chọn số lượng
│   │   ├── rating_stars.dart     # Hiển thị sao đánh giá
│   │   └── review_list.dart      # Danh sách đánh giá
│   │
│   ├── cart/                     # Widget giỏ hàng
│   │   ├── cart_item_tile.dart   # Một sản phẩm trong giỏ
│   │   └── cart_summary.dart     # Tổng tiền giỏ hàng
│   │
│   └── order/                    # Widget đơn hàng
│       ├── order_card.dart       # Thẻ đơn hàng
│       └── order_status_badge.dart # Trạng thái đơn hàng
│
└── utils/                        # Hàm tiện ích dùng chung
    ├── constants.dart            # Hằng số app
    ├── formatters.dart           # Format tiền, ngày tháng
    ├── validators.dart           # Validate form, email, phone
    └── baitap.dart               # File bài tập/test riêng


Cấu trúc thư mục đã hoàn chỉnh và phát triển tiếp các phần tiếp theo
