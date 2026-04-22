import 'package:flutter/material.dart';
import 'electronic_component.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<ElectronicComponent> components;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu linh kiện
    components = [
      ElectronicComponent(
        id: 'C001',
        name: 'Tụ điện',
        category: 'Tụ',
        price: 5000,
        quantity: 100,
        manufacturer: 'Samsung',
        voltage: 50,
        power: 0.5,
        description: 'Tụ điện 10µF 50V',
      ),
      ElectronicComponent(
        id: 'R001',
        name: 'Điện trở',
        category: 'Điện trở',
        price: 1000,
        quantity: 500,
        manufacturer: 'Philips',
        voltage: 10,
        power: 0.25,
        description: 'Điện trở 1kΩ 1/4W',
      ),
      ElectronicComponent(
        id: 'D001',
        name: 'Diode',
        category: 'Diode',
        price: 3000,
        quantity: 200,
        manufacturer: 'Intel',
        voltage: 400,
        power: 1,
        description: 'Diode 1N4007',
      ),
      ElectronicComponent(
        id: 'L001',
        name: 'LED',
        category: 'LED',
        price: 2000,
        quantity: 1000,
        manufacturer: 'Osram',
        voltage: 5,
        power: 0.1,
        description: 'LED đỏ 5mm',
      ),
      ElectronicComponent(
        id: 'T001',
        name: 'Transistor',
        category: 'Transistor',
        price: 4000,
        quantity: 300,
        manufacturer: 'NXP',
        voltage: 20,
        power: 0.5,
        description: 'Transistor NPN 2N2222',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: components.isEmpty
          ? const Center(child: Text('Không có linh kiện nào'))
          : ListView.builder(
              itemCount: components.length,
              itemBuilder: (context, index) {
                final component = components[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(component.id)),
                    title: Text(
                      component.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danh mục: ${component.category}'),
                        Text('Giá: ${component.price.toStringAsFixed(0)} đ'),
                        Text('Số lượng: ${component.quantity}'),
                        Text('Nhà sản xuất: ${component.manufacturer}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.shopping_cart),
                  ),
                );
              },
            ),
    );
  }
}
