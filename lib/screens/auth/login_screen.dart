import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _redirecting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _redirectIfLoggedIn(auth);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:
                        const Icon(Icons.bolt, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Tech Store',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                const Center(
                  child: Text(
                    'Đăng nhập để tiếp tục',
                    style: TextStyle(fontSize: 14, color: AppTheme.grey),
                  ),
                ),
                const SizedBox(height: 40),
                _label('Tài khoản hoặc email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.loginIdentifier,
                  decoration: const InputDecoration(
                    hintText: 'admin hoặc example@email.com',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Mật khẩu'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onFieldSubmitted: (_) {
                    if (!auth.isLoading) _login();
                  },
                  decoration: InputDecoration(
                    hintText: '********',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: auth.isLoading ? null : _resetPassword,
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Đăng nhập'),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: AppTheme.grey),
                    ),
                    GestureDetector(
                      onTap: auth.isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.register,
                              ),
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.grey,
      ),
    );
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (!_formKey.currentState!.validate()) return;

    final ok = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;

    if (!ok) {
      _showSnackBar(auth.errorMessage ?? 'Đăng nhập thất bại');
      return;
    }

    _goAfterLogin(auth);
  }

  Future<void> _resetPassword() async {
    final emailError = Validators.loginIdentifier(_emailCtrl.text);
    if (emailError != null) {
      _showSnackBar(emailError);
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(_emailCtrl.text);
    if (!mounted) return;

    _showSnackBar(
      ok
          ? 'Đã gửi email đặt lại mật khẩu'
          : auth.errorMessage ?? 'Không gửi được email đặt lại mật khẩu',
    );
  }

  void _redirectIfLoggedIn(AuthProvider auth) {
    if (_redirecting || auth.isLoading || !auth.isLoggedIn) return;
    _goAfterLogin(auth);
  }

  void _goAfterLogin(AuthProvider auth) {
    if (_redirecting) return;
    _redirecting = true;
    final route = auth.canManageShop ? AppRoutes.admin : AppRoutes.home;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (_) => false,
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
