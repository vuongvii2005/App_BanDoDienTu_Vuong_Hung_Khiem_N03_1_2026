import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<_AddressItem> _addresses = [
    _AddressItem(
      id: '1',
      name: 'Nguyễn Văn Hùng',
      phone: '0901 234 567',
      address: '123 Đường Láng, Phường Láng Hạ, Quận Đống Đa, Hà Nội',
      isDefault: true,
    ),
    _AddressItem(
      id: '2',
      name: 'Nguyễn Văn Hùng',
      phone: '0901 234 567',
      address: '456 Trần Duy Hưng, Phường Trung Hòa, Quận Cầu Giấy, Hà Nội',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Địa chỉ giao hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildAddressCard(_addresses[i]),
                  ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddressCard(_AddressItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isDefault
              ? AppTheme.primary.withValues(alpha: 0.4)
              : AppTheme.greyLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.isDefault) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.greyLight),
          Row(
            children: [
              if (!item.isDefault)
                Expanded(
                  child: TextButton(
                    onPressed: () => _setDefault(item.id),
                    child: const Text(
                      'Đặt mặc định',
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (!item.isDefault)
                Container(width: 1, height: 32, color: AppTheme.greyLight),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(item),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppTheme.primary),
                  label: const Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 32, color: AppTheme.greyLight),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deleteAddress(item.id),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppTheme.error),
                  label: const Text(
                    'Xóa',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
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
            child: const Icon(
              Icons.location_off_outlined,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thêm địa chỉ để giao hàng nhanh hơn',
            style: TextStyle(fontSize: 13, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Thêm địa chỉ mới'),
      ),
    );
  }

  void _setDefault(String id) {
    setState(() {
      for (final a in _addresses) {
        a.isDefault = a.id == id;
      }
    });
    _showSnack('Đã đặt làm địa chỉ mặc định');
  }

  void _deleteAddress(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xóa địa chỉ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này không?'),
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
              setState(() => _addresses.removeWhere((a) => a.id == id));
              _showSnack('Đã xóa địa chỉ');
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

  void _showAddDialog() => _showAddressForm(null);
  void _showEditDialog(_AddressItem item) => _showAddressForm(item);

  void _showAddressForm(_AddressItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final phoneCtrl = TextEditingController(text: item?.phone ?? '');
    final addressCtrl = TextEditingController(text: item?.address ?? '');
    final isEdit = item != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(
        nameCtrl: nameCtrl,
        phoneCtrl: phoneCtrl,
        addressCtrl: addressCtrl,
        isEdit: isEdit,
        onSave: () {
          if (nameCtrl.text.trim().isEmpty ||
              phoneCtrl.text.trim().isEmpty ||
              addressCtrl.text.trim().isEmpty) {
            _showSnack('Vui lòng điền đầy đủ thông tin');
            return;
          }
          Navigator.pop(context);
          setState(() {
            if (isEdit) {
              final idx = _addresses.indexWhere((a) => a.id == item.id);
              if (idx != -1) {
                _addresses[idx] = _AddressItem(
                  id: item.id,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  isDefault: item.isDefault,
                );
              }
            } else {
              _addresses.add(_AddressItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                isDefault: _addresses.isEmpty,
              ));
            }
          });
          _showSnack(isEdit ? 'Đã cập nhật địa chỉ' : 'Đã thêm địa chỉ mới');
        },
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

class _AddressFormSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final bool isEdit;
  final VoidCallback onSave;

  const _AddressFormSheet({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.isEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                isEdit ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _field(nameCtrl, 'Họ và tên', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(phoneCtrl, 'Số điện thoại', Icons.phone_outlined,
                      type: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field(addressCtrl, 'Địa chỉ chi tiết', Icons.home_outlined,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onSave,
                    child: Text(isEdit ? 'Cập nhật' : 'Lưu địa chỉ'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.grey, size: 20),
        hintStyle: const TextStyle(color: AppTheme.grey, fontSize: 14),
      ),
    );
  }
}

class _AddressItem {
  final String id;
  final String name;
  final String phone;
  final String address;
  bool isDefault;

  _AddressItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.isDefault,
  });
}
