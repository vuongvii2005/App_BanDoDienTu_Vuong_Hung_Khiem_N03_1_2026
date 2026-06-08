import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../providers/user_provider.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().userModel;
    _nameCtrl.text = user?.fullName ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = user?.phone ?? '';
    _addressCtrl.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final avatarUrl = user?.avatarUrl.trim() ?? '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: ClipOval(
                        child: avatarUrl.isEmpty
                            ? Container(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                child: const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: AppTheme.primary,
                                ),
                              )
                            : Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.12),
                                  child: const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ảnh đại diện',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  controller: _nameCtrl,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  readOnly: true,
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _addressCtrl,
                  label: 'Địa chỉ',
                  icon: Icons.location_on_outlined,
                  validator: Validators.required,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final currentUser = auth.userModel;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn cần đăng nhập để cập nhật thông tin')),
      );
      return;
    }

    final updatedUser = currentUser.copyWith(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      updatedAt: DateTime.now(),
    );

    await context.read<UserProvider>().updateUser(updatedUser);
    await context.read<AuthProvider>().reloadUser();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin cá nhân')),
    );

    Navigator.pop(context);
  }
}
