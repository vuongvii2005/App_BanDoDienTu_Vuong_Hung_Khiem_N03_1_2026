import 'package:intl/intl.dart';

class Formatters {
  static String currency(int amount) {
    return '${NumberFormat('#,##0', 'vi_VN').format(amount)} ₫';
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}
