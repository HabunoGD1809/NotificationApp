import 'package:flutter/material.dart';
import 'package:notification_app/models/notification.dart';
import 'package:notification_app/core/utils/date_formatter.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
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
        notification.titulo,
        style: TextStyle(
          fontWeight: notification.leida ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.mensaje),
          Text(
            DateFormatter.timeAgo(notification.fechaCreacion),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      trailing: notification.leida
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle, color: Colors.red),
      onTap: onTap,
    );
  }
}
