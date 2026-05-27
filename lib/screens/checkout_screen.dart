import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Vương Hùng Khiêm');
  final _phoneCtrl = TextEditingController(text: '0901 234 567');
  final _emailCtrl = TextEditingController(text: 'khiemvuong2005@gmail.com');
  final _addressCtrl = TextEditingController(
    text: '123 Nguyễn Văn Cừ, Phường 1',
  );
  final _noteCtrl = TextEditingController();
  String _district = 'Quận 5';
  String _city = 'TP. Hồ Chí Minh';

  @override
  Widget build(BuildContext context) {
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
                // District / City
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
    TextEditingController ctrl, {
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
          controller: ctrl,
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
          value: value,
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
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
          if (_formKey.currentState!.validate()) {
            Navigator.pushNamed(context, AppRoutes.paymentMethod);
          }
        },
        child: const Text('Tiếp tục'),
      ),
    );
  }
}
