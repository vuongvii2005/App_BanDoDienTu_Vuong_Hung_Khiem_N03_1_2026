import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo
          const Text(
            ' TechStore',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          // Menu items
          const Spacer(),
          Row(
            children: const [
              SizedBox(width: 20),
              Text('Products', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Text('Solutions', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Text('Community', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Text('Resources', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Text('Pricing', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Text('Contact', style: TextStyle(fontSize: 14)),
            ],
          ),
          // Sign in / Register buttons
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
