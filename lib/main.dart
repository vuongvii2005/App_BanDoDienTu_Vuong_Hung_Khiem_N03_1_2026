import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'THÀNH VIÊN NHÓM',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text('23016891 - Vi Hùng Vương', style: TextStyle(fontSize: 18)),
            Text('23010092 - Nguyễn Anh Khiêm', style: TextStyle(fontSize: 18)),
            Text(
              '23010103 - Nguyễn Quang Hưng',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
