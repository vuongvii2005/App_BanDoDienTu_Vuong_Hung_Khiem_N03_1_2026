// Hiển thị giá tiền theo format đẹp.

// Ví dụ:

// 120000

// thành:

// 120.000đ

import 'package:flutter/material.dart';

class PriceText extends StatelessWidget {
  final dynamic price;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const PriceText({
    super.key,
    required this.price,
    this.fontSize = 14,
    this.color = const Color(0xFFFF7A3D),
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_formatPrice(price)}đ',
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }

  String _formatPrice(dynamic value) {
    int number = 0;

    if (value is int) {
      number = value;
    } else if (value is double) {
      number = value.toInt();
    } else if (value is String) {
      number = int.tryParse(value) ?? 0;
    }

    final text = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;

      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}