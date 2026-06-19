import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../config/api_config.dart';
import 'package:cat_bracelet_mobile/features/profile//models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/order/screens/order_tracking_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<_AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = UserSession.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/${user.id}'),
        headers: apiHeaders(),
      );

      if (response.statusCode == 200) {
        final orders = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .toList();

        _notifications = orders.map(_notificationFromOrder).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  _AppNotification _notificationFromOrder(Map<String, dynamic> order) {
    final status = (order['status'] ?? '').toString().toUpperCase();
    final orderId = order['id']?.toString() ?? '';
    final shortId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId;
    final createdAtRaw = order['createdAt']?.toString();
    DateTime createdAt = DateTime.now();
    if (createdAtRaw != null) {
      try {
        createdAt = DateTime.parse(createdAtRaw).toLocal();
      } catch (_) {}
    }

    late IconData icon;
    late Color iconColor;
    late String title;
    late String body;

    switch (status) {
      case 'PENDING':
        icon = Icons.shopping_bag_outlined;
        iconColor = AppColors.secondary;
        title = 'Đơn hàng #CB-$shortId đã được đặt';
        body = 'Đơn hàng của bạn đang chờ xác nhận từ cửa hàng.';
      case 'CONFIRMED':
        icon = Icons.check_circle_outline;
        iconColor = AppColors.primaryContainer;
        title = 'Đơn hàng #CB-$shortId đã xác nhận';
        body = 'Nhân viên đang chuẩn bị và đóng gói sản phẩm cho bạn.';
      case 'SHIPPING':
      case 'SHIPPED':
        icon = Icons.local_shipping_outlined;
        iconColor = AppColors.primary;
        title = 'Đơn hàng #CB-$shortId đang vận chuyển';
        body = 'Đơn hàng đã được giao cho đơn vị vận chuyển.';
      case 'OUT_FOR_DELIVERY':
        icon = Icons.delivery_dining;
        iconColor = AppColors.primary;
        title = 'Đơn hàng #CB-$shortId sắp giao';
        body = 'Shipper đang trên đường giao hàng tới bạn.';
      case 'DELIVERED':
      case 'COMPLETED':
        icon = Icons.celebration_outlined;
        iconColor = AppColors.secondary;
        title = 'Đơn hàng #CB-$shortId đã giao';
        body = 'Cảm ơn bạn đã mua sắm tại Cat Bracelet!';
      case 'CANCELLED':
        icon = Icons.cancel_outlined;
        iconColor = const Color(0xFFBA1A1A);
        title = 'Đơn hàng #CB-$shortId đã hủy';
        body = 'Đơn hàng của bạn đã được hủy thành công.';
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppColors.onSurfaceVariant;
        title = 'Cập nhật đơn hàng #CB-$shortId';
        body = 'Trạng thái: ${order['status'] ?? ''}';
    }

    return _AppNotification(
      orderId: orderId,
      title: title,
      body: body,
      icon: icon,
      iconColor: iconColor,
      createdAt: createdAt,
      isRead: status == 'DELIVERED' || status == 'COMPLETED' || status == 'CANCELLED',
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'THÔNG BÁO',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unreadCount mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _notifications.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return _NotificationTile(
                    notification: n,
                    timeAgo: _timeAgo(n.createdAt),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderTrackingScreen(orderId: n.orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thông báo',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cập nhật đơn hàng sẽ hiển thị tại đây',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AppNotification {
  final String orderId;
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final DateTime createdAt;
  final bool isRead;

  const _AppNotification({
    required this.orderId,
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.createdAt,
    required this.isRead,
  });
}

class _NotificationTile extends StatelessWidget {
  final _AppNotification notification;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? Colors.white
          : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.outlineVariant.withValues(alpha: 0.2)
                  : AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(notification.icon, color: notification.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
