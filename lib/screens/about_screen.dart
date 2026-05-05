import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBanner(),
        const Expanded(
          child: Center(
            child: Text(
              "About Screen\nYour Info Here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        buildSimpleFooter(),
      ],
    );
  }
}
