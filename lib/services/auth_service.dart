// Xu ly Firebase Auth va user document tren Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  static const String adminLoginName = 'admin';
  static const String adminEmail = 'admin@techstore.local';

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() => _auth.currentUser;

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: _authEmail(email),
      password: password,
    );
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();

    await user.updateDisplayName(trimmedName);

    final userModel = UserModel(
      id: user.uid,
      uid: user.uid,
      fullName: trimmedName,
      email: trimmedEmail,
      phone: trimmedPhone,
      avatarUrl: '',
      address: '',
      role: UserModel.roleUser,
      isActive: true,
    );

    await _firestore.collection('users').doc(user.uid).set(
          _newUserDocument(
            uid: user.uid,
            email: trimmedEmail,
            fullName: trimmedName,
            phone: trimmedPhone,
            role: UserModel.roleUser,
          ),
        );

    return userModel;
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  Future<UserModel?> getUserModel(String uid) async {
    if (uid.trim().isEmpty) return null;

    final user = _auth.currentUser;
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      if (user == null || user.uid != uid) return null;

      final fallbackName = user.displayName?.trim() ?? '';
      final fallbackEmail = user.email?.trim() ?? '';
      final role = _isConfiguredAdminUser(user)
          ? UserModel.roleAdmin
          : UserModel.roleUser;
      await docRef.set(
        _newUserDocument(
          uid: uid,
          email: fallbackEmail,
          fullName: fallbackName.isEmpty ? fallbackEmail : fallbackName,
          role: role,
        ),
      );
      final createdDoc = await docRef.get();
      return UserModel.fromFirestore(createdDoc);
    }

    final data = doc.data() ?? <String, dynamic>{};
    if (user != null && user.uid == uid && _isConfiguredAdminUser(user)) {
      if (_needsUserDocumentRepair(data, uid) ||
          UserModel.normalizeRole(data['role']) != UserModel.roleAdmin) {
        await docRef.set(
          _repairUserDocument(
            uid: uid,
            user: user,
            data: data,
            role: UserModel.roleAdmin,
          ),
          SetOptions(merge: true),
        );
        final updatedDoc = await docRef.get();
        return UserModel.fromFirestore(updatedDoc);
      }

      return _configuredAdminModel(user, data: data);
    }

    if (_needsUserDocumentRepair(data, uid)) {
      await docRef.set(
        _repairUserDocument(
          uid: uid,
          user: user,
          data: data,
          role: data['role'] is String ? null : UserModel.roleUser,
        ),
        SetOptions(merge: true),
      );
      final updatedDoc = await docRef.get();
      return UserModel.fromFirestore(updatedDoc);
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: _authEmail(email));
  }

  String _authEmail(String value) {
    final login = value.trim();
    if (login.toLowerCase() == adminLoginName) return adminEmail;
    return login;
  }

  bool _isConfiguredAdminUser(User user) {
    return _isConfiguredAdminEmail(user.email);
  }

  bool _isConfiguredAdminEmail(String? value) {
    return value?.trim().toLowerCase() == adminEmail;
  }

  Map<String, dynamic> _newUserDocument({
    required String uid,
    required String email,
    required String fullName,
    String phone = '',
    required String role,
  }) {
    return {
      'id': uid,
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'address': '',
      'avatarUrl': '',
      'role': role,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool _needsUserDocumentRepair(Map<String, dynamic> data, String uid) {
    return data['id'] is! String ||
        (data['id'] as String).trim().isEmpty ||
        (data['id'] as String).trim() != uid ||
        data['uid'] is! String ||
        (data['uid'] as String).trim().isEmpty ||
        (data['uid'] as String).trim() != uid ||
        data['email'] is! String ||
        data['fullName'] is! String ||
        data['phone'] is! String ||
        data['address'] is! String ||
        data['avatarUrl'] is! String ||
        data['role'] is! String ||
        data['isActive'] is! bool;
  }

  Map<String, dynamic> _repairUserDocument({
    required String uid,
    required User? user,
    required Map<String, dynamic> data,
    String? role,
  }) {
    return {
      'id': uid,
      'uid': uid,
      if (data['email'] is! String) 'email': user?.email?.trim() ?? '',
      if (data['fullName'] is! String)
        'fullName': user?.displayName?.trim() ?? user?.email?.trim() ?? '',
      if (data['phone'] is! String) 'phone': '',
      if (data['address'] is! String) 'address': '',
      if (data['avatarUrl'] is! String) 'avatarUrl': '',
      if (role != null) 'role': role,
      if (data['isActive'] is! bool) 'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel _configuredAdminModel(
    User user, {
    Map<String, dynamic>? data,
  }) {
    final fallbackName = user.displayName?.trim() ?? '';
    final fallbackEmail = user.email?.trim() ?? adminEmail;
    final modelData = <String, dynamic>{
      'id': user.uid,
      'uid': user.uid,
      'fullName': fallbackName.isEmpty ? 'Admin' : fallbackName,
      'email': fallbackEmail,
      'phone': '',
      'avatarUrl': '',
      'address': '',
      'isActive': true,
    };

    if (data != null) {
      modelData.addAll(data);
    }

    modelData['id'] = user.uid;
    modelData['uid'] = user.uid;
    modelData['email'] = fallbackEmail;
    modelData['role'] = UserModel.roleAdmin;
    modelData['isActive'] = true;

    return UserModel.fromMap(modelData, id: user.uid, uid: user.uid);
  }

  String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Tài khoản không tồn tại';
        case 'wrong-password':
          return 'Mật khẩu không đúng';
        case 'email-already-in-use':
          return 'Email đã được sử dụng';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không đúng';
        case 'too-many-requests':
          return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau';
        default:
          return 'Đã xảy ra lỗi, vui lòng thử lại';
      }
    }

    if (error is FirebaseException && error.code == 'network-request-failed') {
      return 'Lỗi kết nối mạng';
    }

    return 'Đã xảy ra lỗi, vui lòng thử lại';
  }
}
