//thao tác collection users
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserModel?> getUser(String uid) async {
    if (uid.trim().isEmpty) return null;

    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _users.get();
    final users = snapshot.docs.map(UserModel.fromFirestore).toList();
    users.sort((first, second) {
      final byRole = first.role.compareTo(second.role);
      if (byRole != 0) return byRole;
      return first.fullName.toLowerCase().compareTo(
            second.fullName.toLowerCase(),
          );
    });
    return users;
  }

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).update({
      ...user.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAddress(String uid, String address) async {
    await _users.doc(uid).update({
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _users.doc(uid).update({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRole(String uid, String role) async {
    await _users.doc(uid).update({
      'role': role.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateActive(String uid, bool isActive) async {
    await _users.doc(uid).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
