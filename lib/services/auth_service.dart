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
      uid: user.uid,
      fullName: trimmedName,
      email: trimmedEmail,
      phone: trimmedPhone,
      avatarUrl: '',
      address: '',
      role: UserModel.roleUser,
      isActive: true,
    );

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': trimmedName,
      'email': trimmedEmail,
      'phone': trimmedPhone,
      'avatarUrl': '',
      'address': '',
      'role': UserModel.roleUser,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

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
      await docRef.set({
        'uid': uid,
        'fullName': fallbackName.isEmpty ? fallbackEmail : fallbackName,
        'email': fallbackEmail,
        'phone': '',
        'avatarUrl': '',
        'address': '',
        'role': UserModel.roleUser,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final createdDoc = await docRef.get();
      return UserModel.fromFirestore(createdDoc);
    }

    final data = doc.data() ?? <String, dynamic>{};
    if (data['role'] is! String || data['isActive'] is! bool) {
      await docRef.set({
        'uid': uid,
        if (data['fullName'] is! String)
          'fullName': user?.displayName?.trim() ?? '',
        if (data['email'] is! String) 'email': user?.email?.trim() ?? '',
        if (data['role'] is! String) 'role': UserModel.roleUser,
        if (data['isActive'] is! bool) 'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
