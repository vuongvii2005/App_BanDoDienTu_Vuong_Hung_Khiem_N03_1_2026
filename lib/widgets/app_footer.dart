import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.devices_other_outlined,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'TechStore',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cửa hàng công nghệ uy tín với sản phẩm chính hãng, giá tốt và hỗ trợ tận tâm.',
            style: TextStyle(
              color: AppTheme.grey,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const _FooterInfoRow(
            icon: Icons.phone_outlined,
            label: 'Hotline',
            value: '1800-1234',
          ),
          const SizedBox(height: 10),
          const _FooterInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@techstore.vn',
          ),
          const SizedBox(height: 10),
          const _FooterInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: '123 Nguyễn Văn Linh, Quận 7, TP. Hồ Chí Minh',
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppTheme.greyLight),
          const SizedBox(height: 14),
          Text(
            '© $year TechStore. All rights reserved.',
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _FooterInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.black,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
