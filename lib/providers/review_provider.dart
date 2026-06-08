import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({ReviewService? reviewService})
      : _reviewService = reviewService ?? ReviewService();

  final ReviewService _reviewService;

  final Map<String, List<ReviewModel>> _reviewsByProductId =
      <String, List<ReviewModel>>{};
  final Set<String> _loadingProductIds = <String>{};
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  List<ReviewModel> getReviews(String productId) {
    return List.unmodifiable(_reviewsByProductId[productId] ?? <ReviewModel>[]);
  }

  bool isLoading(String productId) {
    return _loadingProductIds.contains(productId);
  }

  Future<void> loadReviews(String productId, {bool force = false}) async {
    if (productId.trim().isEmpty) return;
    if (!force && _reviewsByProductId.containsKey(productId)) return;
    if (_loadingProductIds.contains(productId)) return;

    _loadingProductIds.add(productId);
    _error = null;
    notifyListeners();

    try {
      _reviewsByProductId[productId] =
          await _reviewService.getReviewsByProduct(productId);
    } catch (error) {
      _error = 'Khong tai duoc danh gia';
      _reviewsByProductId[productId] = <ReviewModel>[];
    } finally {
      _loadingProductIds.remove(productId);
      notifyListeners();
    }
  }

  Future<bool> saveReview({
    required String userId,
    required String userName,
    required String productId,
    required double rating,
    required String comment,
    String orderId = '',
    List<String> images = const <String>[],
  }) async {
    if (userId.trim().isEmpty ||
        productId.trim().isEmpty ||
        comment.trim().isEmpty) {
      _error = 'Vui long nhap noi dung danh gia';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewService.saveReview(
        ReviewModel(
          id: '',
          userId: userId,
          userName: userName,
          productId: productId,
          orderId: orderId,
          rating: rating,
          comment: comment.trim(),
          images: images,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await loadReviews(productId, force: true);
      return true;
    } catch (error) {
      _error = 'Khong luu duoc danh gia';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(String reviewId, String productId) async {
    if (reviewId.trim().isEmpty) return;

    _error = null;
    notifyListeners();

    try {
      await _reviewService.deleteReview(reviewId);
      await loadReviews(productId, force: true);
    } catch (error) {
      _error = 'Khong xoa duoc danh gia';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
