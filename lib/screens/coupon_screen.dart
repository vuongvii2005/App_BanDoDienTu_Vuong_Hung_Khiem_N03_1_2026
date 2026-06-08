import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeCtrl = TextEditingController();

  final List<_Coupon> _available = [
    _Coupon(
      id: '1',
      code: 'HUNG10',
      title: 'Giảm 10% đơn hàng',
      description: 'Áp dụng cho tất cả sản phẩm',
      discount: '10%',
      minOrder: 200000,
      expiry: '30/06/2025',
      type: CouponType.percent,
      used: false,
    ),
    _Coupon(
      id: '2',
      code: 'SHIP0',
      title: 'Miễn phí vận chuyển',
      description: 'Áp dụng cho đơn từ 300k',
      discount: 'Freeship',
      minOrder: 300000,
      expiry: '15/07/2025',
      type: CouponType.shipping,
      used: false,
    ),
    _Coupon(
      id: '3',
      code: 'GAME50K',
      title: 'Giảm 50.000đ',
      description: 'Áp dụng cho phụ kiện gaming',
      discount: '50K',
      minOrder: 500000,
      expiry: '20/07/2025',
      type: CouponType.fixed,
      used: false,
    ),
    _Coupon(
      id: '4',
      code: 'NEWUSER',
      title: 'Giảm 15% cho khách mới',
      description: 'Chỉ dùng 1 lần cho đơn đầu tiên',
      discount: '15%',
      minOrder: 100000,
      expiry: '31/12/2025',
      type: CouponType.percent,
      used: false,
    ),
  ];

  final List<_Coupon> _used = [
    _Coupon(
      id: '5',
      code: 'SALE20',
      title: 'Giảm 20% Flash Sale',
      description: 'Đã sử dụng',
      discount: '20%',
      minOrder: 200000,
      expiry: '01/05/2025',
      type: CouponType.percent,
      used: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mã giảm giá'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.grey,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(text: 'Có thể dùng (${_available.length})'),
                Tab(text: 'Đã dùng (${_used.length})'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildInputRow(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponList(_available, false),
                _buildCouponList(_used, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Nhập mã giảm giá',
                prefixIcon: Icon(Icons.confirmation_number_outlined,
                    color: AppTheme.grey, size: 20),
                hintStyle: TextStyle(color: AppTheme.grey, fontSize: 14),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _applyCode,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 48),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList(List<_Coupon> coupons, bool isUsed) {
    if (coupons.isEmpty) {
      return _buildEmpty(isUsed);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCouponCard(coupons[i]),
    );
  }

  Widget _buildCouponCard(_Coupon coupon) {
    final color = _typeColor(coupon.type);
    return Opacity(
      opacity: coupon.used ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: coupon.used
                ? AppTheme.greyLight
                : color.withValues(alpha: 0.30),
          ),
          boxShadow: coupon.used
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left color strip + discount
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: coupon.used ? 0.06 : 0.10),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(_typeIcon(coupon.type),
                      color: coupon.used ? AppTheme.grey : color, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    coupon.discount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: coupon.used ? AppTheme.grey : color,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Dotted separator
            _buildDottedDivider(
                color: coupon.used ? AppTheme.greyLight : color),
            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coupon.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  coupon.used ? AppTheme.grey : AppTheme.black,
                            ),
                          ),
                        ),
                        if (!coupon.used)
                          GestureDetector(
                            onTap: () => _copyCode(coupon.code),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.30)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coupon.code,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.copy, size: 12, color: color),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.grey, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 12, color: AppTheme.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Đơn tối thiểu ${_formatMoney(coupon.minOrder)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.grey),
                        ),
                        const Spacer(),
                        Text(
                          coupon.used ? 'Đã dùng' : 'HSD: ${coupon.expiry}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                coupon.used ? AppTheme.grey : AppTheme.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (!coupon.used) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _useCoupon(coupon),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 32),
                            backgroundColor: color,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Dùng ngay'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedDivider({required Color color}) {
    return SizedBox(
      width: 12,
      height: 100,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }

  Widget _buildEmpty(bool isUsed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: AppTheme.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            isUsed ? 'Chưa dùng mã nào' : 'Không có mã giảm giá',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.black),
          ),
          const SizedBox(height: 6),
          const Text('Nhập mã ở trên để áp dụng',
              style: TextStyle(fontSize: 13, color: AppTheme.grey)),
        ],
      ),
    );
  }

  Color _typeColor(CouponType type) {
    switch (type) {
      case CouponType.percent:
        return AppTheme.primary;
      case CouponType.fixed:
        return const Color(0xFF7B5EA7);
      case CouponType.shipping:
        return const Color(0xFF1565C0);
    }
  }

  IconData _typeIcon(CouponType type) {
    switch (type) {
      case CouponType.percent:
        return Icons.percent;
      case CouponType.fixed:
        return Icons.currency_exchange;
      case CouponType.shipping:
        return Icons.local_shipping_outlined;
    }
  }

  String _formatMoney(int amount) {
    if (amount >= 1000000) return '${amount ~/ 1000000}tr';
    if (amount >= 1000) return '${amount ~/ 1000}k';
    return '$amount đ';
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnack('Đã sao chép mã "$code"');
  }

  void _applyCode() {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showSnack('Vui lòng nhập mã giảm giá');
      return;
    }
    final found = _available.any((c) => c.code == code);
    if (found) {
      _showSnack('Mã "$code" hợp lệ! Đã áp dụng');
      _codeCtrl.clear();
    } else {
      _showSnack('Mã "$code" không hợp lệ hoặc đã hết hạn');
    }
  }

  void _useCoupon(_Coupon coupon) {
    _showSnack('Đã chọn mã "${coupon.code}" - Áp dụng khi thanh toán');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

enum CouponType { percent, fixed, shipping }

class _Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discount;
  final int minOrder;
  final String expiry;
  final CouponType type;
  final bool used;

  const _Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.minOrder,
    required this.expiry,
    required this.type,
    required this.used,
  });
}
