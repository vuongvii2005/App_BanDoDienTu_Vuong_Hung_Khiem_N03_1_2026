import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _district = 'Quận 1';
  String _city = 'TP. Hồ Chí Minh';
  bool _filledFromUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filledFromUser) return;

    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone;
      _emailCtrl.text = user.email;
      _addressCtrl.text = user.address;
      _filledFromUser = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    if (!auth.isLoggedIn) {
      return _messageScaffold(
        title: 'Thông tin giao hàng',
        message: 'Cần đăng nhập để thanh toán',
        button: 'Đăng nhập',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
      );
    }

    if (cart.items.isEmpty) {
      return _messageScaffold(
        title: 'Thông tin giao hàng',
        message: 'Giỏ hàng đang trống',
        button: 'Quay lại',
        onPressed: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Thông tin giao hàng')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard([
                _field('Họ và tên', _nameCtrl, validator: Validators.required),
                const SizedBox(height: 14),
                _field(
                  'Số điện thoại',
                  _phoneCtrl,
                  keyboard: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),
                _field(
                  'Email',
                  _emailCtrl,
                  keyboard: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                _field('Địa chỉ', _addressCtrl, validator: Validators.required),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _dropdown('Quận/Huyện', _district, [
                        'Quận 1',
                        'Quận 3',
                        'Quận 5',
                        'Quận 7',
                        'Quận 10',
                      ], (v) => setState(() => _district = v!)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dropdown('Tỉnh/Thành phố', _city, [
                        'TP. Hồ Chí Minh',
                        'Hà Nội',
                        'Đà Nẵng',
                      ], (v) => setState(() => _city = v!)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _field(
                  'Ghi chú (không bắt buộc)',
                  _noteCtrl,
                  hint: 'Ghi chú cho đơn hàng...',
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  Widget _messageScaffold({
    required String title,
    required String message,
    required String button,
    required VoidCallback onPressed,
  }) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onPressed, child: Text(button)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      color: AppTheme.white,
      child: ElevatedButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;

          Navigator.pushNamed(
            context,
            AppRoutes.paymentMethod,
            arguments: {
              'fullName': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'phone': _phoneCtrl.text.trim(),
              'address': '${_addressCtrl.text.trim()}, $_district, $_city',
              'note': _noteCtrl.text.trim(),
            },
          );
        },
        child: const Text('Tiếp tục'),
      ),
    );
  }
}
