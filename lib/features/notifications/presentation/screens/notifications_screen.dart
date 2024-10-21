import 'package:flutter/material.dart';
import 'package:notification_app/models/notification.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/core/widgets/loading_indicator.dart';
import 'package:notification_app/features/notifications/presentation/widgets/notification_list_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay notificaciones'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return NotificationListItem(
                  notification: notification,
                  onTap: () => _markAsRead(notification),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await ApiService.markNotificationAsRead(notification.id);
      setState(() {
        _notificationsFuture = ApiService.getNotifications();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación marcada como leída')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar la notificación como leída: ${e.toString()}')),
      );
    }
  }
}