import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/formatters.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({super.key});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  static const _fallbackDuration = Duration(hours: 2, minutes: 18, seconds: 45);

  late DateTime _startedAt;
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _now = _startedAt;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().hotDeals;
    if (products.isEmpty) return const SizedBox.shrink();

    final targetEndAt = _nearestDealEndAt(products);
    final remaining = _countdownDuration(targetEndAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Deal hot hôm nay',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                _Countdown(duration: remaining),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _FlashSaleProductCard(product: products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _nearestDealEndAt(List<Product> products) {
    DateTime? nearest;
    for (final product in products) {
      final endAt = product.dealEndAt;
      if (endAt == null || !endAt.isAfter(_now)) continue;
      if (nearest == null || endAt.isBefore(nearest)) nearest = endAt;
    }
    return nearest;
  }

  Duration _countdownDuration(DateTime? endAt) {
    final remaining = endAt?.difference(_now);
    if (remaining != null &&
        remaining > Duration.zero &&
        remaining <= const Duration(hours: 99)) {
      return remaining;
    }

    final elapsedSeconds = _now.difference(_startedAt).inSeconds;
    final cycleSeconds = _fallbackDuration.inSeconds;
    return Duration(seconds: cycleSeconds - (elapsedSeconds % cycleSeconds));
  }
}

class _Countdown extends StatelessWidget {
  final Duration duration;

  const _Countdown({required this.duration});

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours.remainder(100).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final values = [hours, minutes, seconds];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: values.asMap().entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (entry.key < 2)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _FlashSaleProductCard extends StatelessWidget {
  final Product product;

  const _FlashSaleProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final salePrice = product.effectivePrice;
    final sold = _soldCount(product);
    final total = _dealTotal(product, sold);
    final progress = total <= 0 ? 0.0 : sold / total;

    return SizedBox(
      width: 154,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        ),
        borderRadius: BorderRadius.circular(14),
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
              Stack(
                children: [
                  SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: ColoredBox(
                      color: AppTheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
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
                            Icons.image_outlined,
                            color: AppTheme.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 36,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        Formatters.currency(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.grey,
                          fontSize: 11.5,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        Formatters.currency(salePrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        total > 0 ? 'Đã bán $sold/$total' : 'Đang mở bán',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: progress.clamp(0.0, 1.0).toDouble(),
                          backgroundColor: AppTheme.greyLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppTheme.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 31,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productDetail,
                            arguments: product.id,
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Mua ngay',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
  }

  int _soldCount(Product product) {
    if (product.dealSold < 0) return 0;
    final total = product.dealStock ?? 0;
    if (total <= 0) return product.dealSold;
    return product.dealSold > total ? total : product.dealSold;
  }

  int _dealTotal(Product product, int sold) {
    final dealStock = product.dealStock ?? 0;
    if (dealStock > 0) return dealStock;
    if (product.totalStock > 0) return product.totalStock + sold;
    return 0;
  }
}
