import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  final _emailFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _redirecting = false;

  // Danh sách tài khoản đã lưu
  List<String> _savedAccounts = [];
  // Danh sách đang lọc theo những gì người dùng gõ
  List<String> _filteredAccounts = [];
  bool _showSuggestions = false;

  static const _prefsKey = 'saved_login_accounts';

  @override
  void initState() {
    super.initState();
    _loadSavedAccounts();

    _emailCtrl.addListener(_onEmailChanged);

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        // Khi focus vào field → hiện toàn bộ danh sách
        setState(() {
          _filteredAccounts = List.from(_savedAccounts);
          _showSuggestions = _savedAccounts.isNotEmpty;
        });
      } else {
        // Khi mất focus → ẩn dropdown sau 1 chút (để kịp xử lý tap)
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_onEmailChanged);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // Lọc danh sách theo text đang gõ
  void _onEmailChanged() {
    final query = _emailCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = List.from(_savedAccounts);
      } else {
        _filteredAccounts = _savedAccounts
            .where((acc) => acc.toLowerCase().contains(query))
            .toList();
      }
      _showSuggestions =
          _emailFocusNode.hasFocus && _filteredAccounts.isNotEmpty;
    });
  }

  // Đọc danh sách đã lưu từ SharedPreferences
  Future<void> _loadSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = List<String>.from(jsonDecode(raw));
      if (mounted) setState(() => _savedAccounts = list);
    }
  }

  // Lưu email mới vào danh sách (tối đa 5, mới nhất lên đầu)
  Future<void> _saveAccount(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ..._savedAccounts.where((e) => e != trimmed),
    ].take(5).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(updated));
    if (mounted) setState(() => _savedAccounts = updated);
  }

  // Xoá 1 tài khoản khỏi danh sách gợi ý
  Future<void> _removeAccount(String email) async {
    final updated = _savedAccounts.where((e) => e != email).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(updated));
    setState(() {
      _savedAccounts = updated;
      _filteredAccounts = _filteredAccounts.where((e) => e != email).toList();
      _showSuggestions = _filteredAccounts.isNotEmpty;
    });
  }

  // Chọn tài khoản từ dropdown
  void _selectAccount(String email) {
    _emailCtrl.text = email;
    _emailCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: email.length));
    setState(() => _showSuggestions = false);
    // Chuyển focus sang ô mật khẩu
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) FocusScope.of(context).nextFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _redirectIfLoggedIn(auth);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: GestureDetector(
          // Tap ra ngoài → ẩn dropdown
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _showSuggestions = false);
          },
          behavior: HitTestBehavior.translucent,
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
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Tech Store',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
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

                  // ── Field email + dropdown gợi ý ──
                  _buildEmailFieldWithSuggestions(),

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
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
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
      ),
    );
  }

  /// Field email kèm dropdown gợi ý tài khoản đã lưu
  Widget _buildEmailFieldWithSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailCtrl,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.loginIdentifier,
          decoration: const InputDecoration(
            hintText: 'admin hoặc example@email.com',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),

        // Dropdown gợi ý
        if (_showSuggestions && _filteredAccounts.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.greyLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Tối đa hiện 4 item, mỗi item cao 52px
            constraints: BoxConstraints(
              maxHeight: _filteredAccounts.length > 4
                  ? 4 * 52.0
                  : _filteredAccounts.length * 52.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredAccounts.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final account = _filteredAccounts[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectAccount(account),
                      child: SizedBox(
                        height: 52,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  account,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Nút xoá tài khoản khỏi danh sách gợi ý
                              GestureDetector(
                                onTap: () => _removeAccount(account),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
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

    // Lưu tài khoản vào danh sách gợi ý sau khi đăng nhập thành công
    await _saveAccount(_emailCtrl.text.trim());

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
