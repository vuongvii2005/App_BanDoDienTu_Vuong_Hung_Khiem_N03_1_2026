// Thông tin người dùng
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String? address;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    this.address,
    required this.createdAt,
  });

  // Convert from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, fullName: $fullName)';
  }
}