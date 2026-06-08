import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedIndex;
  final TextEditingController _msgCtrl = TextEditingController();

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'Tôi có thể đổi trả hàng như thế nào?',
      answer:
          'Bạn có thể yêu cầu đổi trả trong vòng 7 ngày kể từ ngày nhận hàng. Sản phẩm cần còn nguyên seal, không có dấu hiệu sử dụng. Liên hệ hotline 1800-1234 hoặc tạo yêu cầu trả hàng trong mục "Đơn hàng của tôi".',
    ),
    _FaqItem(
      question: 'Thời gian giao hàng mất bao lâu?',
      answer:
          'Nội thành Hà Nội & TP.HCM: 1-2 ngày làm việc. Các tỉnh thành khác: 3-5 ngày làm việc. Đơn hàng giao nhanh (express) sẽ có thêm phí và được giao trong ngày.',
    ),
    _FaqItem(
      question: 'Làm sao để theo dõi đơn hàng?',
      answer:
          'Vào mục "Đơn hàng" trên ứng dụng, chọn đơn hàng cần theo dõi. Bạn sẽ thấy trạng thái cập nhật liên tục và mã vận đơn để tra cứu trên website của đơn vị vận chuyển.',
    ),
    _FaqItem(
      question: 'Tôi quên mật khẩu, phải làm gì?',
      answer:
          'Chọn "Quên mật khẩu" ở màn hình đăng nhập, nhập email đã đăng ký. Hệ thống sẽ gửi link đặt lại mật khẩu vào email của bạn trong vài phút.',
    ),
    _FaqItem(
      question: 'Các hình thức thanh toán được chấp nhận?',
      answer:
          'Chúng tôi chấp nhận: Tiền mặt khi nhận hàng (COD), Chuyển khoản ngân hàng, Ví MoMo, ZaloPay, VNPay và thẻ tín dụng/ghi nợ quốc tế.',
    ),
    _FaqItem(
      question: 'Sản phẩm có bảo hành không?',
      answer:
          'Tất cả sản phẩm chính hãng đều có bảo hành theo chính sách của nhà sản xuất (thường 12-24 tháng). Thông tin bảo hành chi tiết có ở trang sản phẩm.',
    ),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactBanner(),
          const SizedBox(height: 20),
          _buildSectionLabel('Liên hệ nhanh'),
          const SizedBox(height: 10),
          _buildContactGrid(),
          const SizedBox(height: 20),
          _buildSectionLabel('Câu hỏi thường gặp'),
          const SizedBox(height: 10),
          _buildFaqList(),
          const SizedBox(height: 20),
          _buildSectionLabel('Gửi yêu cầu hỗ trợ'),
          const SizedBox(height: 10),
          _buildContactForm(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildContactBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.85),
            AppTheme.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hung Gaming Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hỗ trợ 24/7 - Sẵn sàng giúp bạn',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                    SizedBox(width: 6),
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildContactGrid() {
    final contacts = [
      _ContactOption(
        icon: Icons.phone_outlined,
        label: 'Hotline',
        value: '1800-1234',
        color: AppTheme.success,
        onTap: () => _showSnack('Đang kết nối tổng đài 1800-1234...'),
      ),
      _ContactOption(
        icon: Icons.chat_bubble_outline,
        label: 'Live Chat',
        value: 'Chat ngay',
        color: AppTheme.primary,
        onTap: () => _showSnack('Đang mở cửa sổ chat...'),
      ),
      _ContactOption(
        icon: Icons.email_outlined,
        label: 'Email',
        value: 'support@hung.vn',
        color: const Color(0xFF1565C0),
        onTap: () => _showSnack('Đang mở email...'),
      ),
      _ContactOption(
        icon: Icons.groups_outlined,
        label: 'Cộng đồng',
        value: 'Facebook Group',
        color: const Color(0xFF7B5EA7),
        onTap: () => _showSnack('Đang mở Facebook...'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: contacts.map(_buildContactCard).toList(),
    );
  }

  Widget _buildContactCard(_ContactOption option) {
    return GestureDetector(
      onTap: option.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: option.color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, color: option.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey,
                    ),
                  ),
                  Text(
                    option.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: option.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _faqs.asMap().entries.map((entry) {
          final i = entry.key;
          final faq = entry.value;
          final isLast = i == _faqs.length - 1;
          final isOpen = _expandedIndex == i;

          return Column(
            children: [
              InkWell(
                onTap: () => setState(
                  () => _expandedIndex = isOpen ? null : i,
                ),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : BorderRadius.zero,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'Q',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isOpen ? Colors.white : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faq.question,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    isOpen ? AppTheme.primary : AppTheme.black,
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: isOpen
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        faq.answer,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.grey,
                                          height: 1.5,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.grey, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 48,
                    endIndent: 14,
                    color: AppTheme.greyLight),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả vấn đề của bạn',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _msgCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung cần hỗ trợ...',
              hintStyle: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _sendRequest,
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  void _sendRequest() {
    if (_msgCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập nội dung cần hỗ trợ');
      return;
    }
    _msgCtrl.clear();
    _showSnack('Đã gửi yêu cầu! Chúng tôi sẽ phản hồi trong 24h');
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

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _ContactOption {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
}
