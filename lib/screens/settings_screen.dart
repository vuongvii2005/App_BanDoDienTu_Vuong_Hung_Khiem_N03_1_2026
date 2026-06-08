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
  String _selectedLang = 'vi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.greyLight,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppTheme.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // ── Thông báo ─────────────────────────────────────────────
          _sectionLabel('Thông báo'),
          const SizedBox(height: 8),
          _card([
            _toggleTile(
              icon: Icons.notifications_outlined,
              iconColor: AppTheme.primary,
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo từ ứng dụng',
              value: _pushNotification,
              onChanged: (v) => setState(() {
                _pushNotification = v;
                if (!v) _orderNotification = false;
              }),
            ),
            _divider(),
            _toggleTile(
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF2E7D32),
              title: 'Thông báo đơn hàng',
              subtitle: 'Cập nhật trạng thái đơn hàng',
              value: _orderNotification,
              onChanged: (v) => setState(() => _orderNotification = v),
              enabled: _pushNotification,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Tài khoản ─────────────────────────────────────────────
          _sectionLabel('Tài khoản'),
          const SizedBox(height: 8),
          _card([
            _navTile(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF1565C0),
              title: 'Đổi mật khẩu',
              onTap: () => _showChangePasswordSheet(),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Ngôn ngữ ──────────────────────────────────────────────
          _sectionLabel('Ngôn ngữ & Khu vực'),
          const SizedBox(height: 8),
          _card([
            _selectTile(
              icon: Icons.language_outlined,
              iconColor: const Color(0xFF1565C0),
              title: 'Ngôn ngữ',
              value: _selectedLang == 'vi' ? '🇻🇳 Tiếng Việt' : '🇺🇸 English',
              onTap: _showLangPicker,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Dữ liệu ───────────────────────────────────────────────
          _sectionLabel('Dữ liệu & Quyền riêng tư'),
          const SizedBox(height: 8),
          _card([
            _navTile(
              icon: Icons.history_outlined,
              iconColor: AppTheme.grey,
              title: 'Xóa lịch sử tìm kiếm',
              onTap: _showClearSearchDialog,
            ),
            _divider(),
            _navTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF1565C0),
              title: 'Chính sách quyền riêng tư',
              onTap: () => _showInfoSheet(
                title: 'Chính sách quyền riêng tư',
                content: 'Tech Store cam kết bảo vệ thông tin cá nhân của bạn. '
                    'Dữ liệu chỉ được sử dụng để cải thiện trải nghiệm mua sắm '
                    'và sẽ không được chia sẻ với bên thứ ba khi chưa có sự đồng ý.',
              ),
            ),
            _divider(),
            _navTile(
              icon: Icons.article_outlined,
              iconColor: AppTheme.grey,
              title: 'Điều khoản dịch vụ',
              onTap: () => _showInfoSheet(
                title: 'Điều khoản dịch vụ',
                content:
                    'Khi sử dụng Tech Store, bạn đồng ý tuân thủ các điều khoản '
                    'và điều kiện của chúng tôi. Vui lòng đọc kỹ trước khi đặt hàng.',
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Ứng dụng ──────────────────────────────────────────────
          _sectionLabel('Ứng dụng'),
          const SizedBox(height: 8),
          _card([
            _infoTile(
              icon: Icons.info_outline,
              iconColor: AppTheme.grey,
              title: 'Phiên bản',
              value: 'v1.0.0',
            ),
          ]),

          const SizedBox(height: 20),

          // ── Vùng nguy hiểm ────────────────────────────────────────
          _card([
            _navTile(
              icon: Icons.delete_forever_outlined,
              iconColor: AppTheme.error,
              title: 'Xóa tài khoản',
              titleColor: AppTheme.error,
              onTap: _showDeleteAccountDialog,
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.grey,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Card container ─────────────────────────────────────────────────────

  Widget _card(List<Widget> children) {
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

  Widget _divider() => const Divider(
        height: 1,
        indent: 52,
        endIndent: 14,
        color: AppTheme.greyLight,
      );

  // ── Toggle tile ────────────────────────────────────────────────────────

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
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

  // ── Nav tile ───────────────────────────────────────────────────────────

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = AppTheme.black,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
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
            const Icon(Icons.chevron_right, color: AppTheme.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Select tile ────────────────────────────────────────────────────────

  Widget _selectTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
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

  // ── Info tile (read-only) ──────────────────────────────────────────────

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, iconColor),
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

  // ── Icon box helper ────────────────────────────────────────────────────

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // ── Bottom sheets & dialogs ────────────────────────────────────────────

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
            const SizedBox(height: 8),
            _langOption('vi', '🇻🇳', 'Tiếng Việt'),
            const Divider(height: 1, indent: 56, color: AppTheme.greyLight),
            _langOption('en', '🇺🇸', 'English'),
            const SizedBox(height: 28),
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

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.greyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _pwField(
                    controller: currentCtrl,
                    label: 'Mật khẩu hiện tại',
                    obscure: obscureCurrent,
                    onToggle: () =>
                        setModalState(() => obscureCurrent = !obscureCurrent),
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    controller: newCtrl,
                    label: 'Mật khẩu mới',
                    obscure: obscureNew,
                    onToggle: () =>
                        setModalState(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    controller: confirmCtrl,
                    label: 'Xác nhận mật khẩu mới',
                    obscure: obscureConfirm,
                    onToggle: () =>
                        setModalState(() => obscureConfirm = !obscureConfirm),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showSnack('Mật khẩu đã được cập nhật');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cập nhật',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pwField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: AppTheme.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppTheme.grey),
        filled: true,
        fillColor: AppTheme.greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppTheme.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _showInfoSheet({required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.grey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
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
        title: const Text(
          'Xóa lịch sử tìm kiếm',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: const Text(
          'Toàn bộ lịch sử tìm kiếm sẽ bị xóa vĩnh viễn.',
          style: TextStyle(fontSize: 14, color: AppTheme.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppTheme.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Đã xóa lịch sử tìm kiếm');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Xóa',
                style: TextStyle(fontWeight: FontWeight.w700)),
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
        title: const Text(
          'Xóa tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppTheme.error,
          ),
        ),
        content: const Text(
          'Hành động này không thể hoàn tác.\nTất cả dữ liệu sẽ bị xóa vĩnh viễn.',
          style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style:
                  TextStyle(color: AppTheme.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: gọi AuthProvider.deleteAccount()
              _showSnack('Đang xử lý yêu cầu...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xóa tài khoản',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
