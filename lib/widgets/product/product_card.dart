import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : 220.0;

        return SizedBox(
          height: cardHeight,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: product.id,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.greyLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 112,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: AppTheme.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_outlined,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 17,
                              color: AppTheme.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                height: 1.28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 16,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.star,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _priceText(product),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _priceText(Product product) {
    return Formatters.currency(product.minPrice);
  }
}
