import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewService {
  ReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  Future<List<ReviewModel>> getReviewsByProduct(String productId) async {
    if (productId.trim().isEmpty) return <ReviewModel>[];

    final snapshot =
        await _reviews.where('productId', isEqualTo: productId).get();
    final reviews = snapshot.docs.map(ReviewModel.fromFirestore).toList();
    reviews
        .sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return reviews;
  }

  Future<List<ReviewModel>> getReviewsByUser(String uid) async {
    if (uid.trim().isEmpty) return <ReviewModel>[];

    final snapshot = await _reviews.where('userId', isEqualTo: uid).get();
    final reviews = snapshot.docs.map(ReviewModel.fromFirestore).toList();
    reviews
        .sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return reviews;
  }

  Future<ReviewModel?> getReviewById(String reviewId) async {
    if (reviewId.trim().isEmpty) return null;

    final doc = await _reviews.doc(reviewId).get();
    if (!doc.exists) return null;
    return ReviewModel.fromFirestore(doc);
  }

  Future<String> saveReview(ReviewModel review) async {
    if (review.userId.trim().isEmpty) {
      throw ArgumentError('User id is required for reviews.');
    }
    if (review.productId.trim().isEmpty) {
      throw ArgumentError('Product id is required for reviews.');
    }

    final reviewId = review.id.trim().isEmpty
        ? '${review.userId}_${review.productId}'
        : review.id.trim();
    final docRef = _reviews.doc(reviewId);
    final existing = await docRef.get();
    final existingCreatedAt = existing.data()?['createdAt'];

    await docRef.set({
      ...review.copyWith(id: docRef.id).toMap(),
      'id': docRef.id,
      'createdAt': existingCreatedAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  Future<void> deleteReview(String reviewId) async {
    if (reviewId.trim().isEmpty) return;
    await _reviews.doc(reviewId).delete();
  }
}
