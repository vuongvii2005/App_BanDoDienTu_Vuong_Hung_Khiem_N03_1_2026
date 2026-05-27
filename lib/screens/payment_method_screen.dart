import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selected = 'COD';

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'COD',
      'title': 'Thanh toán khi nhận hàng',
      'subtitle': '(COD)',
      'icon': Icons.local_shipping_outlined,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'CARD',
      'title': 'Thẻ tín dụng / Ghi nợ',
      'subtitle': 'Visa, MasterCard, JCB',
      'icon': Icons.credit_card_outlined,
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'MOMO',
      'title': 'Ví điện tử',
      'subtitle': 'MoMo, ZaloPay, ShopeePay',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFE91E8C),
    },
    {
      'id': 'BANK',
      'title': 'Chuyển khoản ngân hàng',
      'subtitle': '',
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF607D8B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Phương thức thanh toán')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _methods.asMap().entries.map((e) {
                      final i = e.key;
                      final m = e.value;
                      final isSelected = _selected == m['id'];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _selected = m['id']),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Radio
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.grey,
                                        width: isSelected ? 6 : 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: (m['color'] as Color).withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      m['icon'] as IconData,
                                      color: m['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if ((m['subtitle'] as String)
                                            .isNotEmpty)
                                          Text(
                                            m['subtitle'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // MoMo logo
                                  if (m['id'] == 'MOMO')
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE91E8C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'M',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (i < _methods.length - 1)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Bottom total + confirm
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Formatters.currency(cart.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.orderConfirm,
                    arguments: _selected,
                  ),
                  child: const Text('Xác nhận thanh toán'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
