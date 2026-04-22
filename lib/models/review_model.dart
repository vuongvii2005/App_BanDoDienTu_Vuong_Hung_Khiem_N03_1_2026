class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final List<String>? images;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    this.images,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    }
    return '${(difference.inDays / 30).floor()} tháng trước';
  }

  String get ratingLabel {
    if (rating >= 4.5) return 'Xuất sắc';
    if (rating >= 4) return 'Rất tốt';
    if (rating >= 3) return 'Tốt';
    if (rating >= 2) return 'Bình thường';
    return 'Không tốt';
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      images:
          json['images'] != null ? List<String>.from(json['images']) : null,
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Review(id: $id, productId: $productId, rating: $rating)';
}
