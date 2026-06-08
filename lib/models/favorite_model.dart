import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String productId;
  final DateTime? createdAt;

  const FavoriteModel({
    required this.id,
    required this.productId,
    this.createdAt,
  });

  factory FavoriteModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return FavoriteModel.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FavoriteModel(
      id: id ?? _string(map['id']),
      productId: _string(map['productId'] ?? id),
      createdAt: _date(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'createdAt': createdAt,
      };

  FavoriteModel copyWith({
    String? id,
    String? productId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
