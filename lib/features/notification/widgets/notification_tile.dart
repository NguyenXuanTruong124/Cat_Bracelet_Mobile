import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationTile
    extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead
          ? null
          : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            notification.type == 'ORDER'
                ? Icons.shopping_bag
                : Icons.notifications,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
            notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.message,
        ),
        trailing: notification.isRead
            ? null
            : const Icon(
          Icons.circle,
          color: Colors.red,
          size: 12,
        ),
        onTap: onTap,
      ),
    );
  }
}