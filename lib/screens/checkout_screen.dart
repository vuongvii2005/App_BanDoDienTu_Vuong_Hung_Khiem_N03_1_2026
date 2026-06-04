import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _city = 'TP. Hồ Chí Minh';
  late String _district;
  bool _filledFromUser = false;

  // ══════════════════════════════════════════════════════════════
  // DỮ LIỆU 63 TỈNH THÀNH & QUẬN/HUYỆN ĐẦY ĐỦ
  // ══════════════════════════════════════════════════════════════
  static const Map<String, List<String>> _districtsByCity = {
    'TP. Hồ Chí Minh': [
      'Quận 1',
      'Quận 3',
      'Quận 4',
      'Quận 5',
      'Quận 6',
      'Quận 7',
      'Quận 8',
      'Quận 10',
      'Quận 11',
      'Quận 12',
      'Bình Thạnh',
      'Gò Vấp',
      'Phú Nhuận',
      'Tân Bình',
      'Tân Phú',
      'Bình Tân',
      'Thủ Đức',
      'Bình Chánh',
      'Cần Giờ',
      'Củ Chi',
      'Hóc Môn',
      'Nhà Bè',
    ],
    'Hà Nội': [
      'Ba Đình',
      'Hoàn Kiếm',
      'Tây Hồ',
      'Long Biên',
      'Cầu Giấy',
      'Đống Đa',
      'Hai Bà Trưng',
      'Hoàng Mai',
      'Thanh Xuân',
      'Nam Từ Liêm',
      'Bắc Từ Liêm',
      'Hà Đông',
      'Sơn Tây',
      'Ba Vì',
      'Chương Mỹ',
      'Đan Phượng',
      'Đông Anh',
      'Gia Lâm',
      'Hoài Đức',
      'Mê Linh',
      'Mỹ Đức',
      'Phú Xuyên',
      'Phúc Thọ',
      'Quốc Oai',
      'Sóc Sơn',
      'Thạch Thất',
      'Thanh Oai',
      'Thanh Trì',
      'Thường Tín',
      'Ứng Hòa',
    ],
    'Đà Nẵng': [
      'Hải Châu',
      'Thanh Khê',
      'Sơn Trà',
      'Ngũ Hành Sơn',
      'Liên Chiểu',
      'Cẩm Lệ',
      'Hòa Vang',
      'Hoàng Sa',
    ],
    'An Giang': [
      'Long Xuyên',
      'Châu Đốc',
      'An Phú',
      'Châu Phú',
      'Châu Thành',
      'Chợ Mới',
      'Phú Tân',
      'Thoại Sơn',
      'Tịnh Biên',
      'Tri Tôn',
    ],
    'Bà Rịa - Vũng Tàu': [
      'Vũng Tàu',
      'Bà Rịa',
      'Châu Đức',
      'Côn Đảo',
      'Đất Đỏ',
      'Long Điền',
      'Tân Thành',
      'Xuyên Mộc',
    ],
    'Bắc Giang': [
      'Bắc Giang',
      'Hiệp Hòa',
      'Lạng Giang',
      'Lục Nam',
      'Lục Ngạn',
      'Sơn Động',
      'Tân Yên',
      'Việt Yên',
      'Yên Dũng',
      'Yên Thế',
    ],
    'Bắc Kạn': [
      'Bắc Kạn',
      'Ba Bể',
      'Bạch Thông',
      'Chợ Đồn',
      'Chợ Mới',
      'Na Rì',
      'Ngân Sơn',
      'Pác Nặm',
    ],
    'Bạc Liêu': [
      'Bạc Liêu',
      'Đông Hải',
      'Giá Rai',
      'Hòa Bình',
      'Hồng Dân',
      'Phước Long',
      'Vĩnh Lợi',
    ],
    'Bắc Ninh': [
      'Bắc Ninh',
      'Từ Sơn',
      'Gia Bình',
      'Lương Tài',
      'Quế Võ',
      'Thuận Thành',
      'Tiên Du',
      'Yên Phong',
    ],
    'Bến Tre': [
      'Bến Tre',
      'Ba Tri',
      'Bình Đại',
      'Châu Thành',
      'Chợ Lách',
      'Giồng Trôm',
      'Mỏ Cày Bắc',
      'Mỏ Cày Nam',
      'Thạnh Phú',
    ],
    'Bình Định': [
      'Quy Nhơn',
      'An Lão',
      'An Nhơn',
      'Hoài Ân',
      'Hoài Nhơn',
      'Phù Cát',
      'Phù Mỹ',
      'Tây Sơn',
      'Tuy Phước',
      'Vân Canh',
      'Vĩnh Thạnh',
    ],
    'Bình Dương': [
      'Thủ Dầu Một',
      'Bắc Tân Uyên',
      'Bàu Bàng',
      'Bến Cát',
      'Dầu Tiếng',
      'Dĩ An',
      'Phú Giáo',
      'Tân Uyên',
      'Thuận An',
    ],
    'Bình Phước': [
      'Đồng Xoài',
      'Bình Long',
      'Phước Long',
      'Bù Đăng',
      'Bù Đốp',
      'Bù Gia Mập',
      'Chơn Thành',
      'Đồng Phú',
      'Hớn Quản',
      'Lộc Ninh',
    ],
    'Bình Thuận': [
      'Phan Thiết',
      'La Gi',
      'Bắc Bình',
      'Đức Linh',
      'Hàm Tân',
      'Hàm Thuận Bắc',
      'Hàm Thuận Nam',
      'Phú Quý',
      'Tánh Linh',
      'Tuy Phong',
    ],
    'Cà Mau': [
      'Cà Mau',
      'Cái Nước',
      'Đầm Dơi',
      'Năm Căn',
      'Ngọc Hiển',
      'Phú Tân',
      'Thới Bình',
      'Trần Văn Thời',
      'U Minh',
    ],
    'Cần Thơ': [
      'Ninh Kiều',
      'Bình Thủy',
      'Cái Răng',
      'Ô Môn',
      'Thốt Nốt',
      'Cờ Đỏ',
      'Phong Điền',
      'Thới Lai',
      'Vĩnh Thạnh',
    ],
    'Cao Bằng': [
      'Cao Bằng',
      'Bảo Lạc',
      'Bảo Lâm',
      'Hà Quảng',
      'Hạ Lang',
      'Hòa An',
      'Nguyên Bình',
      'Quảng Hòa',
      'Thạch An',
      'Trùng Khánh',
    ],
    'Đắk Lắk': [
      'Buôn Ma Thuột',
      'Buôn Đôn',
      'Cư Kuin',
      'Cư Mgar',
      'Ea Hleo',
      'Ea Kar',
      'Ea Súp',
      'Krông Ana',
      'Krông Bông',
      'Krông Búk',
      'Krông Năng',
      'Krông Pắc',
      'Lắk',
      'MDrắk',
    ],
    'Đắk Nông': [
      'Gia Nghĩa',
      'Cư Jút',
      'Đắk Glong',
      'Đắk Mil',
      'Đắk RLấp',
      'Đắk Song',
      'Krông Nô',
      'Tuy Đức',
    ],
    'Điện Biên': [
      'Điện Biên Phủ',
      'Mường Lay',
      'Điện Biên',
      'Điện Biên Đông',
      'Mường Ảng',
      'Mường Chà',
      'Mường Nhé',
      'Nậm Pồ',
      'Tủa Chùa',
      'Tuần Giáo',
    ],
    'Đồng Nai': [
      'Biên Hòa',
      'Long Khánh',
      'Cẩm Mỹ',
      'Định Quán',
      'Long Thành',
      'Nhơn Trạch',
      'Tân Phú',
      'Thống Nhất',
      'Trảng Bom',
      'Vĩnh Cửu',
      'Xuân Lộc',
    ],
    'Đồng Tháp': [
      'Cao Lãnh',
      'Sa Đéc',
      'Hồng Ngự',
      'Châu Thành',
      'Lai Vung',
      'Lấp Vò',
      'Tam Nông',
      'Tân Hồng',
      'Tháp Mười',
      'Thanh Bình',
    ],
    'Gia Lai': [
      'Pleiku',
      'An Khê',
      'Ayun Pa',
      'Chư Păh',
      'Chư Prông',
      'Chư Pưh',
      'Chư Sê',
      'Đắk Đoa',
      'Đắk Pơ',
      'Đức Cơ',
      'Ia Grai',
      'Ia Pa',
      'KBang',
      'Kông Chro',
      'Krông Pa',
      'Mang Yang',
      'Phú Thiện',
    ],
    'Hà Giang': [
      'Hà Giang',
      'Bắc Mê',
      'Bắc Quang',
      'Đồng Văn',
      'Hoàng Su Phì',
      'Mèo Vạc',
      'Quản Bạ',
      'Quang Bình',
      'Vị Xuyên',
      'Xín Mần',
      'Yên Minh',
    ],
    'Hà Nam': [
      'Phủ Lý',
      'Bình Lục',
      'Duy Tiên',
      'Kim Bảng',
      'Lý Nhân',
      'Thanh Liêm',
    ],
    'Hà Tĩnh': [
      'Hà Tĩnh',
      'Hồng Lĩnh',
      'Kỳ Anh',
      'Cẩm Xuyên',
      'Can Lộc',
      'Đức Thọ',
      'Hương Khê',
      'Hương Sơn',
      'Lộc Hà',
      'Nghi Xuân',
      'Thạch Hà',
      'Vũ Quang',
    ],
    'Hải Dương': [
      'Hải Dương',
      'Chí Linh',
      'Bình Giang',
      'Cẩm Giàng',
      'Gia Lộc',
      'Kim Thành',
      'Kinh Môn',
      'Nam Sách',
      'Ninh Giang',
      'Tứ Kỳ',
      'Thanh Miện',
    ],
    'Hải Phòng': [
      'Hồng Bàng',
      'Lê Chân',
      'Ngô Quyền',
      'Kiến An',
      'Hải An',
      'Đồ Sơn',
      'Dương Kinh',
      'An Dương',
      'An Lão',
      'Bạch Long Vĩ',
      'Cát Hải',
      'Kiến Thụy',
      'Tiên Lãng',
      'Thủy Nguyên',
      'Vĩnh Bảo',
    ],
    'Hậu Giang': [
      'Vị Thanh',
      'Ngã Bảy',
      'Châu Thành',
      'Châu Thành A',
      'Long Mỹ',
      'Phụng Hiệp',
      'Vị Thủy',
    ],
    'Hòa Bình': [
      'Hòa Bình',
      'Cao Phong',
      'Đà Bắc',
      'Kim Bôi',
      'Kỳ Sơn',
      'Lạc Sơn',
      'Lạc Thủy',
      'Lương Sơn',
      'Mai Châu',
      'Tân Lạc',
      'Yên Thủy',
    ],
    'Hưng Yên': [
      'Hưng Yên',
      'Ân Thi',
      'Khoái Châu',
      'Kim Động',
      'Mỹ Hào',
      'Phù Cừ',
      'Tiên Lữ',
      'Văn Giang',
      'Văn Lâm',
      'Yên Mỹ',
    ],
    'Khánh Hòa': [
      'Nha Trang',
      'Cam Ranh',
      'Diên Khánh',
      'Khánh Sơn',
      'Khánh Vĩnh',
      'Ninh Hòa',
      'Trường Sa',
      'Vạn Ninh',
      'Cam Lâm',
    ],
    'Kiên Giang': [
      'Rạch Giá',
      'Hà Tiên',
      'Phú Quốc',
      'An Biên',
      'An Minh',
      'Châu Thành',
      'Giang Thành',
      'Giồng Riềng',
      'Gò Quao',
      'Hòn Đất',
      'Kiên Hải',
      'Kiên Lương',
      'Tân Hiệp',
      'U Minh Thượng',
      'Vĩnh Thuận',
    ],
    'Kon Tum': [
      'Kon Tum',
      'Đắk Glei',
      'Đắk Hà',
      'Đắk Tô',
      'Ia HDrai',
      'Kon Plông',
      'Kon Rẫy',
      'Ngọc Hồi',
      'Sa Thầy',
      'Tu Mơ Rông',
    ],
    'Lai Châu': [
      'Lai Châu',
      'Mường Tè',
      'Nậm Nhùn',
      'Phong Thổ',
      'Sìn Hồ',
      'Tam Đường',
      'Tân Uyên',
      'Than Uyên',
    ],
    'Lâm Đồng': [
      'Đà Lạt',
      'Bảo Lộc',
      'Bảo Lâm',
      'Cát Tiên',
      'Di Linh',
      'Đạ Huoai',
      'Đạ Tẻh',
      'Đam Rông',
      'Đơn Dương',
      'Đức Trọng',
      'Lạc Dương',
      'Lâm Hà',
    ],
    'Lạng Sơn': [
      'Lạng Sơn',
      'Bắc Sơn',
      'Bình Gia',
      'Cao Lộc',
      'Chi Lăng',
      'Đình Lập',
      'Hữu Lũng',
      'Lộc Bình',
      'Tràng Định',
      'Văn Lãng',
      'Văn Quan',
    ],
    'Lào Cai': [
      'Lào Cai',
      'Bắc Hà',
      'Bảo Thắng',
      'Bảo Yên',
      'Bát Xát',
      'Mường Khương',
      'Sa Pa',
      'Si Ma Cai',
      'Văn Bàn',
    ],
    'Long An': [
      'Tân An',
      'Kiến Tường',
      'Bến Lức',
      'Cần Đước',
      'Cần Giuộc',
      'Châu Thành',
      'Đức Hòa',
      'Đức Huệ',
      'Mộc Hóa',
      'Tân Hưng',
      'Tân Thạnh',
      'Tân Trụ',
      'Thạnh Hóa',
      'Thủ Thừa',
      'Vĩnh Hưng',
    ],
    'Nam Định': [
      'Nam Định',
      'Giao Thủy',
      'Hải Hậu',
      'Mỹ Lộc',
      'Nam Trực',
      'Nghĩa Hưng',
      'Trực Ninh',
      'Vụ Bản',
      'Xuân Trường',
      'Ý Yên',
    ],
    'Nghệ An': [
      'Vinh',
      'Cửa Lò',
      'Hoàng Mai',
      'Thái Hòa',
      'Anh Sơn',
      'Con Cuông',
      'Diễn Châu',
      'Đô Lương',
      'Hưng Nguyên',
      'Kỳ Sơn',
      'Nam Đàn',
      'Nghi Lộc',
      'Nghĩa Đàn',
      'Quế Phong',
      'Quỳ Châu',
      'Quỳ Hợp',
      'Quỳnh Lưu',
      'Tân Kỳ',
      'Thanh Chương',
      'Tương Dương',
      'Yên Thành',
    ],
    'Ninh Bình': [
      'Ninh Bình',
      'Tam Điệp',
      'Gia Viễn',
      'Hoa Lư',
      'Kim Sơn',
      'Nho Quan',
      'Yên Khánh',
      'Yên Mô',
    ],
    'Ninh Thuận': [
      'Phan Rang - Tháp Chàm',
      'Bác Ái',
      'Ninh Hải',
      'Ninh Phước',
      'Ninh Sơn',
      'Thuận Bắc',
      'Thuận Nam',
    ],
    'Phú Thọ': [
      'Việt Trì',
      'Phú Thọ',
      'Cẩm Khê',
      'Đoan Hùng',
      'Hạ Hòa',
      'Lâm Thao',
      'Phù Ninh',
      'Tam Nông',
      'Tân Sơn',
      'Thanh Ba',
      'Thanh Sơn',
      'Thanh Thủy',
      'Yên Lập',
    ],
    'Phú Yên': [
      'Tuy Hòa',
      'Sông Cầu',
      'Đồng Xuân',
      'Đông Hòa',
      'Phú Hòa',
      'Sơn Hòa',
      'Sông Hinh',
      'Tây Hòa',
      'Tuy An',
    ],
    'Quảng Bình': [
      'Đồng Hới',
      'Ba Đồn',
      'Bố Trạch',
      'Lệ Thủy',
      'Minh Hóa',
      'Quảng Ninh',
      'Quảng Trạch',
      'Tuyên Hóa',
    ],
    'Quảng Nam': [
      'Tam Kỳ',
      'Hội An',
      'Bắc Trà My',
      'Duy Xuyên',
      'Đại Lộc',
      'Điện Bàn',
      'Đông Giang',
      'Hiệp Đức',
      'Nam Giang',
      'Nam Trà My',
      'Nông Sơn',
      'Núi Thành',
      'Phú Ninh',
      'Phước Sơn',
      'Quế Sơn',
      'Tây Giang',
      'Thăng Bình',
      'Tiên Phước',
    ],
    'Quảng Ngãi': [
      'Quảng Ngãi',
      'Ba Tơ',
      'Bình Sơn',
      'Đức Phổ',
      'Lý Sơn',
      'Minh Long',
      'Mộ Đức',
      'Nghĩa Hành',
      'Sơn Hà',
      'Sơn Tây',
      'Sơn Tịnh',
      'Tây Trà',
      'Tư Nghĩa',
      'Trà Bồng',
    ],
    'Quảng Ninh': [
      'Hạ Long',
      'Cẩm Phả',
      'Uông Bí',
      'Móng Cái',
      'Đông Triều',
      'Quảng Yên',
      'Ba Chẽ',
      'Bình Liêu',
      'Cô Tô',
      'Đầm Hà',
      'Hải Hà',
      'Hoành Bồ',
      'Tiên Yên',
      'Vân Đồn',
    ],
    'Quảng Trị': [
      'Đông Hà',
      'Quảng Trị',
      'Cam Lộ',
      'Cồn Cỏ',
      'Đakrong',
      'Gio Linh',
      'Hải Lăng',
      'Hướng Hóa',
      'Triệu Phong',
      'Vĩnh Linh',
    ],
    'Sóc Trăng': [
      'Sóc Trăng',
      'Châu Thành',
      'Cù Lao Dung',
      'Kế Sách',
      'Long Phú',
      'Mỹ Tú',
      'Mỹ Xuyên',
      'Ngã Năm',
      'Thạnh Trị',
      'Trần Đề',
      'Vĩnh Châu',
    ],
    'Sơn La': [
      'Sơn La',
      'Bắc Yên',
      'Mai Sơn',
      'Mộc Châu',
      'Mường La',
      'Phù Yên',
      'Quỳnh Nhai',
      'Sông Mã',
      'Sốp Cộp',
      'Thuận Châu',
      'Vân Hồ',
      'Yên Châu',
    ],
    'Tây Ninh': [
      'Tây Ninh',
      'Bến Cầu',
      'Châu Thành',
      'Dương Minh Châu',
      'Gò Dầu',
      'Hòa Thành',
      'Tân Biên',
      'Tân Châu',
      'Trảng Bàng',
    ],
    'Thái Bình': [
      'Thái Bình',
      'Đông Hưng',
      'Hưng Hà',
      'Kiến Xương',
      'Quỳnh Phụ',
      'Thái Thụy',
      'Tiền Hải',
      'Vũ Thư',
    ],
    'Thái Nguyên': [
      'Thái Nguyên',
      'Sông Công',
      'Phổ Yên',
      'Đại Từ',
      'Định Hóa',
      'Đồng Hỷ',
      'Phú Bình',
      'Phú Lương',
      'Võ Nhai',
    ],
    'Thanh Hóa': [
      'Thanh Hóa',
      'Bỉm Sơn',
      'Sầm Sơn',
      'Bá Thước',
      'Cẩm Thủy',
      'Đông Sơn',
      'Hà Trung',
      'Hậu Lộc',
      'Hoằng Hóa',
      'Lang Chánh',
      'Mường Lát',
      'Nga Sơn',
      'Ngọc Lặc',
      'Như Thanh',
      'Như Xuân',
      'Nông Cống',
      'Quan Hóa',
      'Quan Sơn',
      'Quảng Xương',
      'Thạch Thành',
      'Thiệu Hóa',
      'Thọ Xuân',
      'Thường Xuân',
      'Tĩnh Gia',
      'Triệu Sơn',
      'Vĩnh Lộc',
      'Yên Định',
    ],
    'Thừa Thiên Huế': [
      'Huế',
      'Hương Thủy',
      'Hương Trà',
      'A Lưới',
      'Nam Đông',
      'Phong Điền',
      'Phú Lộc',
      'Phú Vang',
      'Quảng Điền',
    ],
    'Tiền Giang': [
      'Mỹ Tho',
      'Gò Công',
      'Cai Lậy',
      'Cái Bè',
      'Châu Thành',
      'Chợ Gạo',
      'Gò Công Đông',
      'Gò Công Tây',
      'Tân Phú Đông',
      'Tân Phước',
    ],
    'Trà Vinh': [
      'Trà Vinh',
      'Duyên Hải',
      'Càng Long',
      'Châu Thành',
      'Cầu Kè',
      'Cầu Ngang',
      'Tiểu Cần',
      'Trà Cú',
    ],
    'Tuyên Quang': [
      'Tuyên Quang',
      'Chiêm Hóa',
      'Hàm Yên',
      'Lâm Bình',
      'Na Hang',
      'Sơn Dương',
      'Yên Sơn',
    ],
    'Vĩnh Long': [
      'Vĩnh Long',
      'Bình Minh',
      'Bình Tân',
      'Long Hồ',
      'Mang Thít',
      'Tam Bình',
      'Trà Ôn',
      'Vũng Liêm',
    ],
    'Vĩnh Phúc': [
      'Vĩnh Yên',
      'Phúc Yên',
      'Bình Xuyên',
      'Lập Thạch',
      'Sông Lô',
      'Tam Đảo',
      'Tam Dương',
      'Vĩnh Tường',
      'Yên Lạc',
    ],
    'Yên Bái': [
      'Yên Bái',
      'Nghĩa Lộ',
      'Lục Yên',
      'Mù Cang Chải',
      'Trạm Tấu',
      'Trấn Yên',
      'Văn Chấn',
      'Văn Yên',
      'Yên Bình',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Khởi tạo quận/huyện mặc định theo tỉnh mặc định
    _district = _districtsByCity[_city]!.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filledFromUser) return;
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone;
      _emailCtrl.text = user.email;
      _addressCtrl.text = user.address;
      _filledFromUser = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    if (auth.isGuest) {
      return _messageScaffold(
        title: 'Thông tin giao hàng',
        message: 'Cần đăng nhập để thanh toán',
        button: 'Đăng nhập',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
      );
    }

    if (!auth.canBuy) {
      return _messageScaffold(
        title: 'Thông tin giao hàng',
        message: 'Tài khoản này không dùng để mua hàng',
        button: 'Về trang chủ',
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
      );
    }

    if (cart.items.isEmpty) {
      return _messageScaffold(
        title: 'Thông tin giao hàng',
        message: 'Giỏ hàng đang trống',
        button: 'Quay lại',
        onPressed: () => Navigator.pop(context),
      );
    }

    final districtOptions = _districtsByCity[_city] ?? const <String>[];
    final cityOptions = _districtsByCity.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Thông tin giao hàng')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard([
                _field(
                  'Họ và tên',
                  _nameCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                _field(
                  'Số điện thoại',
                  _phoneCtrl,
                  keyboard: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),
                _field(
                  'Email',
                  _emailCtrl,
                  keyboard: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                _field(
                  'Địa chỉ',
                  _addressCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),

                // ── Tỉnh/Thành phố ──
                _dropdown(
                  'Tỉnh/Thành phố',
                  _city,
                  cityOptions,
                  (v) {
                    if (v == null) return;
                    setState(() {
                      _city = v;
                      // Reset quận/huyện về đầu danh sách của tỉnh mới
                      _district = _districtsByCity[_city]!.first;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // ── Quận/Huyện — tự động cập nhật theo tỉnh ──
                _dropdown(
                  'Quận/Huyện',
                  _district,
                  districtOptions,
                  (v) {
                    if (v == null) return;
                    setState(() => _district = v);
                  },
                ),
                const SizedBox(height: 14),

                _field(
                  'Ghi chú (không bắt buộc)',
                  _noteCtrl,
                  hint: 'Ghi chú cho đơn hàng...',
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _messageScaffold({
    required String title,
    required String message,
    required String button,
    required VoidCallback onPressed,
  }) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onPressed, child: Text(button)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          menuMaxHeight: 320,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      color: AppTheme.white,
      child: ElevatedButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pushNamed(
            context,
            AppRoutes.paymentMethod,
            arguments: {
              'fullName': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'phone': _phoneCtrl.text.trim(),
              'address': '${_addressCtrl.text.trim()}, $_district, $_city',
              'note': _noteCtrl.text.trim(),
            },
          );
        },
        child: const Text('Tiếp tục'),
      ),
    );
  }
}
