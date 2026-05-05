import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/detail_page.dart';
import 'pages/contact_page.dart';

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
      home: const MainNavigationPage(title: 'Ứng dụng bán đồ điện tử'),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key, required this.title});

  final String title;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndexSelected = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndexSelected = index;
    });
  }

  final List<Widget> _tabs = [
    const HomePage(),
    const DetailPage(),
    const ContactPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _tabs[_currentIndexSelected],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Detail", icon: Icon(Icons.details)),
          BottomNavigationBarItem(
            label: "Contact",
            icon: Icon(Icons.contact_emergency),
          ),
        ],
        currentIndex: _currentIndexSelected,
        onTap: _onItemTapped,
      ),
    );
  }
}
