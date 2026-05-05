import 'package:flutter/material.dart';
import '../entities/list_electronic_component.dart';
import '../widgets/screen_template.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listService = ListElectronicComponent();
    final components = listService.readAll();

    Widget bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách linh kiện điện tử',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...components.map((component) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Danh mục: ${component.category}'),
                    Text('Giá: ${component.price} VND'),
                    Text('Số lượng: ${component.quantity}'),
                    Text('Nhà sản xuất: ${component.manufacturer}'),
                    Text('Điện áp: ${component.voltage}V'),
                    Text('Công suất: ${component.power}W'),
                    const SizedBox(height: 8),
                    Text(
                      'Mô tả: ${component.description}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );

    return ScreenTemplate(
      groupImagePath: 'https://via.placeholder.com/600x300?text=Danh+Sach+Linh+Kien',
      body: bodyContent,
      studentName: 'Vi Hùng Vương',
    );
  }
}
