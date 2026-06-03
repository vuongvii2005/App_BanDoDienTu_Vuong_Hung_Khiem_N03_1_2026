import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star, color: AppTheme.star, size: size);
          } else if (i < rating) {
            return Icon(Icons.star_half, color: AppTheme.star, size: size);
          }
          return Icon(Icons.star_border, color: AppTheme.star, size: size);
        }),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)',
              style: TextStyle(fontSize: size - 4, color: AppTheme.grey)),
        ],
      ],
    );
  }
}
