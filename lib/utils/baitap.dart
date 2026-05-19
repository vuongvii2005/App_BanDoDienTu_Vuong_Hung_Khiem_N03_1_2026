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
    {'studentID': 's923333', 'fullname': 'Tran Thi  Van'},
  ];

  var printer = DataPrinter(student);
  printer.printData();
}