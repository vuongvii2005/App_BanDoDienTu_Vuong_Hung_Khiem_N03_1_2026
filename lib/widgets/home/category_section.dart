import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

const Map<String, String> _categoryFallbackImages = {
  'phone':
      'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-1-1.jpg',
  'laptop':
      'https://cdn.tgdd.vn/Products/Images/44/282827/apple-macbook-air-m2-2022-01.jpg',
  'tablet':
      'https://cdn.tgdd.vn/Products/Images/522/325534/ipad-pro-13-inch-m4-lte-black-1.jpg',
  'headphone':
      'https://cdn.tgdd.vn/Products/Images/54/289781/airpods-pro-2nd-generation-0.jpg',
  'watch':
      'https://cdn.tgdd.vn/Products/Images/7077/314708/apple-watch-s9-45mm-vien-nhom-day-silicone-trang-starlight-1.jpg',
  'accessory':
      'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-1-org.jpg',
};

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (categoryProvider.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (categoryProvider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          categoryProvider.error!,
          style: const TextStyle(color: AppTheme.grey, fontSize: 13),
        ),
      );
    }

    if (categoryProvider.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Chưa có danh mục',
          style: TextStyle(color: AppTheme.grey, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categoryProvider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          final imageUrl = category.imageUrl.trim().isEmpty
              ? _categoryFallbackImages[category.id] ?? ''
              : category.imageUrl.trim();

          return GestureDetector(
            onTap: () {
              context.read<CategoryProvider>().selectCategory(category.id);
              context.read<ProductProvider>().selectCategory(category.id);
              Navigator.pushNamed(
                context,
                AppRoutes.productList,
                arguments: category.id,
              );
            },
            child: SizedBox(
              width: 64,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: imageUrl.isEmpty
                            ? const Icon(
                                Icons.image_outlined,
                                color: AppTheme.grey,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppTheme.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
