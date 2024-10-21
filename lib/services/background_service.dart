import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/services/local_notification_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Servicio de notificaciones",
            content: "Ejecutándose en segundo plano",
          );
        }
      }

      await _checkForNewNotifications();
    });
  }

  static Future<void> _checkForNewNotifications() async {
    try {
      final notifications = await ApiService.getNotifications();
      for (var notification in notifications) {
        if (!notification.leida) {
          await LocalNotificationService.showNotification(
            id: notification.id.hashCode,
            title: notification.titulo,
            body: notification.mensaje,
          );
        }
      }
    } catch (e) {
      print('Error al verificar nuevas notificaciones: $e');
    }
  }
}