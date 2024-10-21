import 'package:notification_app/features/notifications/domain/notification_repository.dart';
import 'package:notification_app/models/notification.dart';
import 'package:notification_app/services/api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationModel>> getNotifications() async {
    return await ApiService.getNotifications();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await ApiService.markNotificationAsRead(notificationId);
  }
}