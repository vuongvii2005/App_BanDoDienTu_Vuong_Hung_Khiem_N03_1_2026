import 'package:flutter/foundation.dart';

class DataPrinter<T> {
  T obj;

  DataPrinter(this.obj);

  void printData() {
    debugPrint(obj.toString());
  }
}

void main() {
  final student = [
    {'studentID': 's123456', 'fullname': 'Nguyen Thi B'},
    {'studentID': 's345672', 'fullname': 'Nguyen Van D'},
    {'studentID': 's923333', 'fullname': 'Tran Thi Van'},
  ];

  final printer = DataPrinter(student);
  printer.printData();
}
