import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/review_model.dart';
import '../../utils/formatters.dart';
import 'rating_stars.dart';

class ReviewList extends StatelessWidget {
  final List<ReviewModel> reviews;
  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Chưa có đánh giá nào',
              style: TextStyle(color: AppTheme.grey)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 20),
      itemBuilder: (_, i) => _buildItem(reviews[i]),
    );
  }

  Widget _buildItem(ReviewModel r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.greyLight,
          child: Text(r.userName.isNotEmpty ? r.userName[0] : '?',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(Formatters.date(r.createdAt),
                      style:
                          const TextStyle(fontSize: 11, color: AppTheme.grey)),
                ],
              ),
              const SizedBox(height: 4),
              RatingStars(rating: r.rating, size: 14),
              const SizedBox(height: 6),
              Text(r.comment,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.grey, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
