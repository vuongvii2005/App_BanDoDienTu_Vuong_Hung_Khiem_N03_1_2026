import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotification = true;
  bool _orderNotification = true;
  bool _promotionNotification = false;
  bool _soundEnabled = true;
  bool _biometricLogin = false;
  bool _darkMode = false;
  String _selectedLang = 'vi';
  String _selectedCurrency = 'VND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thông báo
          _buildSectionLabel('Thông báo'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildToggleTile(
              icon: Icons.notifications_outlined,
              iconColor: AppTheme.primary,
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo từ ứng dụng',
              value: _pushNotification,
              onChanged: (v) => setState(() => _pushNotification = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              icon: Icons.shopping_bag_outlined,
              iconColor: AppTheme.success,
              title: 'Thông báo đơn hàng',
              subtitle: 'Cập nhật trạng thái đơn hàng',
              value: _orderNotification,
              onChanged: (v) => setState(() => _orderNotification = v),
              enabled: _pushNotification,
            ),
            _buildDivider(),
            _buildToggleTile(
              icon: Icons.local_offer_outlined,
              iconColor: AppTheme.warning,
              title: 'Thông báo khuyến mãi',
              subtitle: 'Ưu đãi, flash sale, voucher mới',
              value: _promotionNotification,
              onChanged: (v) => setState(() => _promotionNotification = v),
              enabled: _pushNotification,
            ),
            _buildDivider(),
            _buildToggleTile(
              icon: Icons.volume_up_outlined,
              iconColor: const Color(0xFF7B5EA7),
              title: 'Âm thanh thông báo',
              subtitle: 'Phát âm khi có thông báo mới',
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
              enabled: _pushNotification,
            ),
          ]),

          const SizedBox(height: 20),

          // Bảo mật
          _buildSectionLabel('Bảo mật & Đăng nhập'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildToggleTile(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF1565C0),
              title: 'Đăng nhập sinh trắc học',
              subtitle: 'Vân tay / Face ID',
              value: _biometricLogin,
              onChanged: (v) => setState(() => _biometricLogin = v),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.lock_outline,
              iconColor: AppTheme.error,
              title: 'Đổi mật khẩu',
              onTap: () => _showSnack('Đang mở trang đổi mật khẩu'),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.success,
              title: 'Xác minh 2 bước (2FA)',
              trailing: _buildBadge('Chưa bật', AppTheme.warning),
              onTap: () => _showSnack('Đang thiết lập xác minh 2 bước'),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.devices_outlined,
              iconColor: AppTheme.grey,
              title: 'Thiết bị đang đăng nhập',
              onTap: () => _showSnack('Đang xem danh sách thiết bị'),
            ),
          ]),

          const SizedBox(height: 20),

          // Giao diện
          _buildSectionLabel('Giao diện'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildToggleTile(
              icon: Icons.dark_mode_outlined,
              iconColor: AppTheme.black,
              title: 'Chế độ tối',
              subtitle: 'Dark mode (Sắp ra mắt)',
              value: _darkMode,
              onChanged: (_) => _showSnack('Tính năng sắp ra mắt'),
            ),
            _buildDivider(),
            _buildSelectTile(
              icon: Icons.language_outlined,
              iconColor: const Color(0xFF1565C0),
              title: 'Ngôn ngữ',
              value: _selectedLang == 'vi' ? '🇻🇳 Tiếng Việt' : '🇺🇸 English',
              onTap: () => _showLangPicker(),
            ),
            _buildDivider(),
            _buildSelectTile(
              icon: Icons.currency_exchange_outlined,
              iconColor: AppTheme.success,
              title: 'Đơn vị tiền tệ',
              value: _selectedCurrency,
              onTap: () => _showSnack('VND là đơn vị mặc định'),
            ),
          ]),

          const SizedBox(height: 20),

          // Dữ liệu & Quyền riêng tư
          _buildSectionLabel('Dữ liệu & Quyền riêng tư'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.history_outlined,
              iconColor: AppTheme.grey,
              title: 'Lịch sử tìm kiếm',
              onTap: () => _showClearSearchDialog(),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF1565C0),
              title: 'Chính sách quyền riêng tư',
              onTap: () => _showSnack('Đang mở chính sách bảo mật'),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.article_outlined,
              iconColor: AppTheme.grey,
              title: 'Điều khoản dịch vụ',
              onTap: () => _showSnack('Đang mở điều khoản'),
            ),
          ]),

          const SizedBox(height: 20),

          // Ứng dụng
          _buildSectionLabel('Ứng dụng'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.star_outline,
              iconColor: AppTheme.star,
              title: 'Đánh giá ứng dụng',
              onTap: () => _showSnack('Đang mở trang đánh giá...'),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.share_outlined,
              iconColor: AppTheme.primary,
              title: 'Chia sẻ ứng dụng',
              onTap: () => _showSnack('Đang mở tùy chọn chia sẻ...'),
            ),
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.info_outline,
              iconColor: AppTheme.grey,
              title: 'Phiên bản ứng dụng',
              value: 'v1.0.0',
            ),
          ]),

          const SizedBox(height: 20),

          // Nguy hiểm
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.delete_forever_outlined,
              iconColor: AppTheme.error,
              title: 'Xóa tài khoản',
              titleColor: AppTheme.error,
              onTap: () => _showDeleteAccountDialog(),
            ),
          ]),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.grey,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
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
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => const Divider(
      height: 1, indent: 52, endIndent: 14, color: AppTheme.greyLight);

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = AppTheme.black,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppTheme.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppTheme.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showLangPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn ngôn ngữ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _langOption('vi', '🇻🇳', 'Tiếng Việt'),
            const Divider(height: 1, indent: 56, color: AppTheme.greyLight),
            _langOption('en', '🇺🇸', 'English'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String code, String flag, String name) {
    final isSelected = _selectedLang == code;
    return InkWell(
      onTap: () {
        setState(() => _selectedLang = code);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
          ],
        ),
      ),
    );
  }

  void _showClearSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa lịch sử tìm kiếm',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Toàn bộ lịch sử tìm kiếm sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy',
                style: TextStyle(
                    color: AppTheme.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Đã xóa lịch sử tìm kiếm');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tài khoản',
            style:
                TextStyle(fontWeight: FontWeight.w800, color: AppTheme.error)),
        content: const Text(
          'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy',
                style: TextStyle(
                    color: AppTheme.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Đang xử lý yêu cầu xóa tài khoản...');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
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
