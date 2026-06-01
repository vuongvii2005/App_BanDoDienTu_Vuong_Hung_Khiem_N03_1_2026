//xử lý Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserModel> register(
    String email,
    String password,
    String fullName,
    String phone,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Không tạo được tài khoản.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    final userModel = UserModel(
      uid: user.uid,
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatarUrl: '',
      address: '',
      role: 'user',
    );

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': userModel.fullName,
      'email': userModel.email,
      'phone': userModel.phone,
      'avatarUrl': '',
      'address': '',
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return userModel;
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        case 'user-not-found':
          return 'Không tìm thấy tài khoản';
        case 'wrong-password':
          return 'Sai mật khẩu';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không đúng';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
      }
      return error.message ?? 'Đăng nhập thất bại';
    }
    return 'Đã có lỗi xảy ra';
  }
}
