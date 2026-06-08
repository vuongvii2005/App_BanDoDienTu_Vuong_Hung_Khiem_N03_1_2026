//cấu trúc dữ liệu người dùng
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const Set<String> customerRoles = {
    roleUser,
    'customer',
    'client',
    'member',
    'khach_hang',
    'khách_hàng',
    'khach hang',
    'khách hàng',
  };

  final String id;
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String address;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    String? id,
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.address = '',
    this.role = 'user',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uid;

  String get name => fullName;
  bool get isUser => customerRoles.contains(role);
  bool get isAdmin => role == roleAdmin;

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return UserModel.fromMap(
      doc.data() ?? <String, dynamic>{},
      id: doc.id,
    );
  }

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
    String? uid,
  }) {
    final role = normalizeRole(map['role']);
    final documentId = _firstNotEmpty(id, uid, map['uid'], map['id']);
    final userUid = _firstNotEmpty(uid, map['uid'], documentId);

    return UserModel(
      id: documentId,
      uid: userUid,
      fullName: _string(map['fullName'] ?? map['name']),
      email: _string(map['email']),
      phone: _string(map['phone']),
      avatarUrl: _string(map['avatarUrl']),
      address: _string(map['address']),
      role: role,
      isActive: map.containsKey('isActive') ? _bool(map['isActive']) : true,
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id.isEmpty ? uid : id,
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'address': address,
        'role': role,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? role,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      role: role == null ? this.role : normalizeRole(role),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static String _firstNotEmpty(Object? first, Object? second, Object? third,
      [Object? fourth]) {
    for (final value in [first, second, third, fourth]) {
      final text = _string(value).trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String normalizeRole(dynamic value) {
    final text = _string(value).trim().toLowerCase();
    if (text.isEmpty) return roleUser;
    final normalized = text.replaceAll(RegExp(r'[\s-]+'), '_');
    if (normalized == roleAdmin) return roleAdmin;
    if (customerRoles.contains(text) || customerRoles.contains(normalized)) {
      return roleUser;
    }
    return text;
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
