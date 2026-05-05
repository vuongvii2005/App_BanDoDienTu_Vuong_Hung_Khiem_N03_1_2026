import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBanner(),
        const Expanded(
          child: Center(
            child: Text("Home Screen", style: TextStyle(fontSize: 22)),
          ),
        ),
        buildSimpleFooter(),
      ],
    );
  }
}
