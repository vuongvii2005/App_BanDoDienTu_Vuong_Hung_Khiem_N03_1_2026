import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  static const String typePercent = 'percent';
  static const String typeFixed = 'fixed';

  final String id;
  final String code;
  final String type;
  final int value;
  final int minOrder;
  final int maxDiscount;
  final int usageLimit;
  final int usedCount;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minOrder = 0,
    this.maxDiscount = 0,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.startAt,
    this.endAt,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPercent => type == typePercent;
  bool get isFixed => type == typeFixed;
  bool get reachedUsageLimit => usageLimit > 0 && usedCount >= usageLimit;

  bool isAvailableFor(int subtotal, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (!isActive || reachedUsageLimit || subtotal < minOrder) return false;
    if (startAt != null && current.isBefore(startAt!)) return false;
    if (endAt != null && current.isAfter(endAt!)) return false;
    return true;
  }

  int discountFor(int subtotal) {
    if (!isAvailableFor(subtotal)) return 0;

    final rawDiscount = isPercent ? subtotal * value ~/ 100 : value;
    final cappedDiscount = maxDiscount > 0 && rawDiscount > maxDiscount
        ? maxDiscount
        : rawDiscount;

    if (cappedDiscount < 0) return 0;
    return cappedDiscount > subtotal ? subtotal : cappedDiscount;
  }

  factory CouponModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CouponModel.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory CouponModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CouponModel(
      id: id ?? _string(map['id']),
      code: _normalizeCode(map['code']),
      type: _normalizeType(map['type']),
      value: _int(map['value']),
      minOrder: _moneyInt(map['minOrder']),
      maxDiscount: _moneyInt(map['maxDiscount']),
      usageLimit: _int(map['usageLimit']),
      usedCount: _int(map['usedCount']),
      startAt: _date(map['startAt']),
      endAt: _date(map['endAt']),
      isActive: map.containsKey('isActive') ? _bool(map['isActive']) : true,
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'type': type,
        'value': value,
        'minOrder': minOrder,
        'maxDiscount': maxDiscount,
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'startAt': startAt,
        'endAt': endAt,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static String normalizeCode(String value) => _normalizeCode(value);

  static String _normalizeCode(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  static String _normalizeType(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == typeFixed ? typeFixed : typePercent;
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _moneyInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    final text = value?.toString().trim() ?? '';
    final parsed = num.tryParse(text.replaceAll(',', ''));
    if (parsed != null) return parsed.round();
    return int.tryParse(text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
