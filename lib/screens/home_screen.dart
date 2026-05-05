import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Image.asset(
            'assets/images/avt-shin.jpg',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Body
          Expanded(
            child: Center(
              child: Text(
                'Welcome to Home Screen',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Phenikaa University - Vương, Khiêm, Hùng',
            ),
          ),
        ],
      ),
    );
  }
}