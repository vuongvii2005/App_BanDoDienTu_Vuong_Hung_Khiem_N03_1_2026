import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../utils/mock_data.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: MockData.categories.map((cat) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productList,
              arguments: cat['name'],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.greyLight),
                  ),
                  child: Center(
                    child: Text(
                      cat['icon']!,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
