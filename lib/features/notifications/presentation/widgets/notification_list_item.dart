import 'package:flutter/material.dart';
import 'package:notification_app/shared/models/notification.dart' as app_notification;
import 'package:notification_app/core/utils/date_formatter.dart';

class NotificationListItem extends StatelessWidget {
  final app_notification.Notification notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          Text(
            DateFormatter.timeAgo(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      trailing: notification.read
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle, color: Colors.red),
      onTap: onTap,
    );
  }
}
