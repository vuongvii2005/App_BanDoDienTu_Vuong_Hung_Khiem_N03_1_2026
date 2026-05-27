class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Vui lòng nhập trường này' : null;

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(v.replaceAll(' ', '')))
      return 'Số điện thoại không hợp lệ';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
      return 'Email không hợp lệ';
    return null;
  }
}
