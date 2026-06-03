class Validators {
  static String? required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Vui lòng nhập trường này'
        : null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }

    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  static String? loginIdentifier(String? value) {
    final login = value?.trim() ?? '';

    if (login.isEmpty) {
      return 'Vui lòng nhập tài khoản hoặc email';
    }

    if (login.toLowerCase() == 'admin') {
      return null;
    }

    return email(login);
  }

  static String? phone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s.-]'), '');

    if (phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final vietnamPhoneRegex =
        RegExp(r'^(0(3|5|7|8|9)[0-9]{8}|(\+84|84)(3|5|7|8|9)[0-9]{8})$');
    if (!vietnamPhoneRegex.hasMatch(phone)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (password.length < 6) {
      return 'Mật khẩu tối thiểu 6 ký tự';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }
}
