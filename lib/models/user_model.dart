//cấu trúc dữ liệu người dùng
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String address;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.address = '',
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  String get id => uid;
  String get name => fullName;
  bool get isUser => role == roleUser;
  bool get isAdmin => role == roleAdmin;

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return UserModel.fromMap(doc.data() ?? <String, dynamic>{}, uid: doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    final role = _string(map['role']).trim().toLowerCase();
    return UserModel(
      uid: uid ?? _string(map['uid'] ?? map['id']),
      fullName: _string(map['fullName'] ?? map['name']),
      email: _string(map['email']),
      phone: _string(map['phone']),
      avatarUrl: _string(map['avatarUrl']),
      address: _string(map['address']),
      role: role.isEmpty ? roleUser : role,
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'address': address,
        'role': role,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? role,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      role: role?.trim().toLowerCase() ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
