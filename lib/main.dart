import 'package:flutter/material.dart';
import 'package:notification_app/app.dart';
import 'package:notification_app/services/local_notification_service.dart';
import 'package:notification_app/services/local_storage_service.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await LocalNotificationService.init();
  await BackgroundService.initializeService();

  final token = await LocalStorageService.getString('access_token');
  if (token != null) {
    ApiService.setToken(token);
  }

  runApp(const NotificationApp());
}