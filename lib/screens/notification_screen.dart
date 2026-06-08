import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotifItem> _items = [
    _NotifItem(
      id: '1',
      title: 'Đơn hàng đã được xác nhận',
      body: 'Đơn hàng #DH001 của bạn đã được xác nhận và đang được xử lý.',
      time: '2 phút trước',
      icon: Icons.check_circle_outline,
      isRead: false,
    ),
    _NotifItem(
      id: '2',
      title: 'Đơn hàng đang được giao',
      body: 'Đơn hàng #DH001 đang trên đường giao đến bạn. Dự kiến hôm nay.',
      time: '1 giờ trước',
      icon: Icons.local_shipping_outlined,
      isRead: false,
    ),
    _NotifItem(
      id: '3',
      title: 'Khuyến mãi hôm nay',
      body: 'Giảm 20% cho tất cả sản phẩm điện thoại. Chỉ trong hôm nay!',
      time: '3 giờ trước',
      icon: Icons.local_offer_outlined,
      isRead: true,
    ),
    _NotifItem(
      id: '4',
      title: 'Chào mừng đến Tech Store',
      body:
          'Cảm ơn bạn đã đăng ký. Khám phá ngay hàng nghìn sản phẩm công nghệ!',
      time: 'Hôm qua',
      icon: Icons.celebration_outlined,
      isRead: true,
    ),
  ];

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      _items.firstWhere((n) => n.id == id).isRead = true;
    });
  }

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
          'Thông báo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: _items.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, index) => _buildTile(_items[index]),
    );
  }

  Widget _buildTile(_NotifItem item) {
    return GestureDetector(
      onTap: () => _markRead(item.id),
      child: Container(
        color: item.isRead
            ? AppTheme.white
            : AppTheme.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.isRead
                    ? AppTheme.greyLight
                    : AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                item.icon,
                color: item.isRead ? AppTheme.grey : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey.withValues(alpha: 0.7),
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
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thông báo đơn hàng & khuyến mãi\nsẽ hiển thị tại đây',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  bool isRead;

  _NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.isRead,
  });
}
