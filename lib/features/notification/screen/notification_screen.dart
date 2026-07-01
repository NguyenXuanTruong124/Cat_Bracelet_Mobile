import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;

  List<NotificationModel> _notifications = [];

  late NotificationService _service;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = NotificationService(context);

      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _service.getNotifications();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _notifications = notifications;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await _service.markAsRead(notification.id);

      setState(() {
        final index = _notifications.indexWhere((e) => e.id == notification.id);

        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            relatedId: notification.relatedId,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }
      });
    }

    if (notification.type == 'ORDER' && notification.relatedId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.orderTracking,
        arguments: notification.relatedId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return NotificationTile(
                    notification: _notifications[index],
                    onTap: () => _onNotificationTap(_notifications[index]),
                  );
                },
              ),
            ),
    );
  }
}
