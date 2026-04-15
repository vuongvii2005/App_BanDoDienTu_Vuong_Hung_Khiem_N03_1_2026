import 'package:flutter/material.dart';

// ĐỐI TƯỢNG MẶT HÀNG
class MatHang {
  final int id;
  final String tenMatHang;
  final int soLuong;
  final double gia;
  final String moTa;

  MatHang({
    required this.id,
    required this.tenMatHang,
    required this.soLuong,
    required this.gia,
    required this.moTa,
  });
}

// ========== ĐỐI TƯỢNG NGƯỜI MUA ==========
class NguoiMua {
  final int id;
  final String tenNguoiDung;
  final String email;
  final String soDienThoai;

  NguoiMua({
    required this.id,
    required this.tenNguoiDung,
    required this.email,
    required this.soDienThoai,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng bán đồ điện tử',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Ứng dụng bán đồ điện tử'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // ========== DANH SÁCH MẶT HÀNG (List) ==========
    List<MatHang> danhSachMatHang = [
      MatHang(
        id: 1,
        tenMatHang: 'Laptop Dell XPS 13',
        soLuong: 5,
        gia: 25000000,
        moTa: 'Laptop cao cấp với hiệu năng mạnh',
      ),
      MatHang(
        id: 2,
        tenMatHang: 'iPhone 15 Pro',
        soLuong: 10,
        gia: 30000000,
        moTa: 'Điện thoại thông minh Apple mới nhất',
      ),
      MatHang(
        id: 3,
        tenMatHang: 'iPad Air',
        soLuong: 7,
        gia: 18000000,
        moTa: 'Máy tính bảng Apple chính hãng',
      ),
    ];

    // ========== DANH SÁCH NGƯỜI MUA (List) ==========
    List<NguoiMua> danhSachNguoiMua = [
      NguoiMua(
        id: 1,
        tenNguoiDung: 'Nguyễn Văn A',
        email: 'nguyenvana@gmail.com',
        soDienThoai: '0909123456',
      ),
      NguoiMua(
        id: 2,
        tenNguoiDung: 'Trần Thị B',
        email: 'tranthib@gmail.com',
        soDienThoai: '0912345678',
      ),
      NguoiMua(
        id: 3,
        tenNguoiDung: 'Lê Minh C',
        email: 'leminc@gmail.com',
        soDienThoai: '0987654321',
      ),
    ];

    // ========== MAP - THÔNG TIN QUẢN TR/TRỊ HỆ THỐNG ==========
    Map<String, dynamic> nguoiQuanTri = {
      'id': 999,
      'tenNguoiDung': 'Admin System',
      'email': 'admin@shop.com',
      'soDienThoai': '0900000000',
      'quyenHan': 'Quản trị viên',
    };

    // ========== MAP - THÔNG TIN CỬA HÀNG ==========
    Map<String, String> thongTinCuaHang = {
      'tenCuaHang': 'SHOP LINH KIỆN ĐIỆN TỬ',
      'dia_chi': '123 Đường Trần Hưng Đạo, TPHCM',
      'sdt': '0900999999',
      'email': 'shop@electronics.com',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // ===== THÔNG TIN CỬA HÀNG =====
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'THÔNG TIN CỬA HÀNG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tên: ${thongTinCuaHang['tenCuaHang']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Địa chỉ: ${thongTinCuaHang['dia_chi']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'SĐT: ${thongTinCuaHang['sdt']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ===== DANH SÁCH MẶT HÀNG =====
              const Text(
                'DANH SÁCH MẶT HÀNG',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...danhSachMatHang.map((matHang) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${matHang.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          matHang.tenMatHang,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Số lượng: ${matHang.soLuong}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Giá: ${matHang.gia.toStringAsFixed(0)} đ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Mô tả: ${matHang.moTa}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              // ===== DANH SÁCH NGƯỜI MUA =====
              const Text(
                'DANH SÁCH NGƯỜI MUA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...danhSachNguoiMua.map((nguoiMua) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${nguoiMua.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          nguoiMua.tenNguoiDung,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Email: ${nguoiMua.email}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'SĐT: ${nguoiMua.soDienThoai}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              // ===== THÔNG TIN QUẢN TRỊ VIÊ =====
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'THÔNG TIN QUẢN TRỊ VIÊN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tên: ${nguoiQuanTri['tenNguoiDung']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Email: ${nguoiQuanTri['email']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'SĐT: ${nguoiQuanTri['soDienThoai']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Quyền: ${nguoiQuanTri['quyenHan']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ===== THÀNH VIÊN NHÓM =====
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: const [
                    Text(
                      'THÀNH VIÊN NHÓM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '23016891 - Vi Hùng Vương',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '23010092 - Nguyễn Anh Khiêm',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '23010103 - Nguyễn Quang Hưng',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
