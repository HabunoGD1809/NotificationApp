import 'package:notification_app/shared/models/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> addNotification(Notification notification);
}