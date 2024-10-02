import 'package:flutter/material.dart';
import 'package:notification_app/shared/models/notification.dart' as app_notification;
import 'package:notification_app/features/notifications/data/mock_notification_repository.dart';
import 'package:notification_app/services/local_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationRepository = MockNotificationRepository();
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await _notificationRepository.getNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationRepository.markAsRead(notificationId);
    await _loadNotifications();
    LocalNotificationService.cancelNotification(int.parse(notificationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.body),
            trailing: notification.read
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
              onPressed: () => _markAsRead(notification.id),
              child: const Text('Marcar como leída'),
            ),
          );
        },
      ),
    );
  }
}
