import 'package:flutter/material.dart';
import 'package:notification_app/app.dart';
import 'package:notification_app/services/local_storage_service.dart';
import 'package:notification_app/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await LocalNotificationService.init();
  runApp(const NotificationApp());
}