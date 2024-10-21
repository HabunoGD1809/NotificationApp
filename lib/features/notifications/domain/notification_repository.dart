import 'package:notification_app/models/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markNotificationAsRead(String notificationId);
}