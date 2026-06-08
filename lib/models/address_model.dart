import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String receiverName;
  final String phone;
  final String city;
  final String district;
  final String ward;
  final String detail;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.city,
    required this.district,
    this.ward = '',
    required this.detail,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullAddress {
    return [detail, ward, district, city]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
  }

  factory AddressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AddressModel.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory AddressModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AddressModel(
      id: id ?? _string(map['id']),
      receiverName: _string(map['receiverName'] ?? map['fullName']),
      phone: _string(map['phone']),
      city: _string(map['city']),
      district: _string(map['district']),
      ward: _string(map['ward']),
      detail: _string(map['detail'] ?? map['address']),
      isDefault: _bool(map['isDefault']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'receiverName': receiverName,
        'phone': phone,
        'city': city,
        'district': district,
        'ward': ward,
        'detail': detail,
        'isDefault': isDefault,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  AddressModel copyWith({
    String? id,
    String? receiverName,
    String? phone,
    String? city,
    String? district,
    String? ward,
    String? detail,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

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
