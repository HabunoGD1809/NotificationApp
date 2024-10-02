import 'package:notification_app/features/notifications/domain/notification_repository.dart';
import 'package:notification_app/shared/models/notification.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<Notification> _notifications = [];

  @override
  Future<List<Notification>> getNotifications() async {
    await Future.delayed(const Duration(seconds: 1)); // Simular retraso de red
    return _notifications;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular retraso de red
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<void> addNotification(Notification notification) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular retraso de red
    _notifications.add(notification);
  }
}