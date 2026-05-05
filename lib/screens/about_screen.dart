import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset(
            'assets/images/avt-shin.jpg',
            height: 1550,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Expanded(
            child: Center(
              child: Text(
                'About Us',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),

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