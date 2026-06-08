import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  String _selected = 'COD';
  bool _isLoading = false;

  // Card form controllers
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'COD',
      'title': 'Thanh toán khi nhận hàng',
      'subtitle': 'Thanh toán trực tiếp khi nhận hàng',
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
      'title': 'MoMo',
      'subtitle': 'Quét mã QR để thanh toán',
      'icon': Icons.qr_code_2,
      'color': Color(0xFFE91E8C),
    },
    {
      'id': 'BANK',
      'title': 'Chuyển khoản ngân hàng',
      'subtitle': 'Quét mã QR hoặc chuyển thủ công',
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF607D8B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final shippingInfo = _shippingInfoFromRoute(context);

    if (auth.isGuest || !auth.canBuy) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Phương thức thanh toán')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              auth.isGuest
                  ? 'Cần đăng nhập để thanh toán'
                  : 'Tài khoản này không dùng để mua hàng',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.grey),
            ),
          ),
        ),
      );
    }

    if (!cart.hasSelectedItems) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Phương thức thanh toán')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Chưa chọn sản phẩm để thanh toán',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_selected != 'COD') {
          _expandController.reverse();
          await Future.delayed(const Duration(milliseconds: 200));
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Phương thức thanh toán'),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPaymentMethods(),
                      const SizedBox(height: 20),
                      if (_selected != 'COD') _buildPaymentDetails(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildBottomAction(context, cart, shippingInfo, auth),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _methods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          final isSelected = _selected == method['id'];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected
                  ? (method['color'] as Color).withValues(alpha: 0.03)
                  : Colors.transparent,
              border: isSelected
                  ? Border(
                      left: BorderSide(
                        color: method['color'] as Color,
                        width: 4,
                      ),
                    )
                  : null,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _selected = method['id'] as String;
                    if (_selected != 'COD') {
                      _expandController.forward();
                    } else {
                      _expandController.reverse();
                    }
                  }),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? method['color'] as Color
                                  : AppTheme.grey,
                              width: isSelected ? 8 : 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (method['color'] as Color)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: method['color'] as Color,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < _methods.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: _selected == 'CARD' ? _buildCardForm() : _buildQRCodeDisplay(),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thẻ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardNumberCtrl,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              hintText: '0000 0000 0000 0000',
              labelText: 'Số thẻ',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              counterText: '',
            ),
            onChanged: (value) {
              // Format card number with spaces
              final cleaned = value.replaceAll(' ', '');
              if (cleaned.length <= 16) {
                final formatted = cleaned
                    .replaceAllMapped(
                      RegExp(r'.{1,4}'),
                      (match) => '${match.group(0)} ',
                    )
                    .trim();
                _cardNumberCtrl.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: formatted.length),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _cardHolderCtrl,
            decoration: InputDecoration(
              hintText: 'Tên chủ thẻ',
              labelText: 'Chủ thẻ',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cardExpiryCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    labelText: 'Hạn sử dụng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    counterText: '',
                  ),
                  onChanged: (value) {
                    // Auto format MM/YY
                    if (value.length == 2 && !value.contains('/')) {
                      _cardExpiryCtrl.value = TextEditingValue(
                        text: '${value.substring(0, 2)}/',
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: 3),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _cardCvvCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '***',
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            _selected == 'MOMO' ? 'Quét mã QR MoMo' : 'Quét mã QR Chuyển khoản',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: _selected == 'MOMO'
                  ? 'https://qr.momo.vn/00012021051410484995u2e'
                  : 'https://qr.techcombank.com.vn/tcb/payment',
              version: QrVersions.auto,
              size: 200.0,
              embeddedImage: null,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD966),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFFC107),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selected == 'MOMO'
                        ? 'Mở ứng dụng MoMo, quét mã QR để thanh toán'
                        : 'Quét mã QR hoặc nhập thông tin tài khoản để chuyển khoản',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    CartProvider cart,
    Map<String, String> shippingInfo,
    AuthProvider auth,
  ) {
    final canPay = !_isLoading && cart.hasSelectedItems;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Formatters.currency(cart.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canPay
                    ? () => _processPayment(
                          context,
                          cart,
                          shippingInfo,
                          auth,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor:
                      AppTheme.primary.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Thanh toán ${Formatters.currency(cart.total)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    CartProvider cart,
    Map<String, String> shippingInfo,
    AuthProvider auth,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final orderProvider = context.read<OrderProvider>();
    final selectedItems = cart.selectedItems;
    final selectedItemIds =
        selectedItems.map((item) => item.id).toList(growable: false);

    if (selectedItems.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Chưa chọn sản phẩm để thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate payment method details
    if (_selected == 'CARD') {
      if (_cardNumberCtrl.text.isEmpty ||
          _cardHolderCtrl.text.isEmpty ||
          _cardExpiryCtrl.text.isEmpty ||
          _cardCvvCtrl.text.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin thẻ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // For COD, skip order confirm and go directly to success
      if (_selected == 'COD') {
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Place order directly
        final orderId = await orderProvider.placeOrder(
          paymentMethod: _selected,
          shippingInfo: shippingInfo,
          userId: auth.currentUser!.uid,
          items: selectedItems,
          total: cart.total,
          subtotal: cart.subtotal,
          discount: cart.discount,
          shippingFee: cart.shippingFee,
          couponCode: cart.couponCode,
        );

        if (!mounted) return;

        if (orderId == null || orderId.trim().isEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                orderProvider.error ?? 'Khong tao duoc don hang',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Clear cart
        cart.removeItemsLocal(selectedItemIds);

        // Navigate to success screen
        navigator.pushReplacementNamed(
          AppRoutes.orderSuccess,
          arguments: orderId,
        );
      } else {
        // For other payment methods, go to order confirm
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        navigator.pushNamed(
          AppRoutes.orderConfirm,
          arguments: {
            'paymentMethod': _selected,
            'shippingInfo': shippingInfo,
            'cardInfo': _selected == 'CARD'
                ? {
                    'cardNumber': _cardNumberCtrl.text,
                    'cardHolder': _cardHolderCtrl.text,
                    'expiry': _cardExpiryCtrl.text,
                  }
                : null,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, String> _shippingInfoFromRoute(BuildContext context) {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, String>) {
        return args;
      } else if (args is Map) {
        // Convert Map (including IdentityMap) to LinkedHashMap<String, String>
        final linkedMap = <String, String>{};
        args.forEach((key, value) {
          final strKey = key is String ? key : key.toString();
          final strValue = value is String ? value : (value?.toString() ?? '');
          linkedMap[strKey] = strValue;
        });
        return linkedMap;
      }
    } catch (e) {
      debugPrint('Error parsing shipping info: $e');
    }
    return <String, String>{};
  }
}
