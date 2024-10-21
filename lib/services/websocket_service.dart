import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:notification_app/config/app_config.dart';
import 'package:notification_app/services/local_notification_service.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static String? _deviceId;

  static void connect(String deviceId) {
    _deviceId = deviceId;
    _initializeConnection();
  }

  static void _initializeConnection() {
    final wsUrl = Uri.parse('${AppConfig.wsUrl}/ws/$_deviceId');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((message) {
      final data = json.decode(message);
      if (data['tipo'] == 'nueva_notificacion' || data['tipo'] == 'notificacion_pendiente') {
        LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: data['notificacion']['titulo'],
          body: data['notificacion']['mensaje'],
        );
      }
    }, onDone: () {
      // Reconectar si la conexión se cierra
      Future.delayed(const Duration(seconds: 5), _initializeConnection);
    }, onError: (error) {
      print('WebSocket error: $error');
      // Reconectar en caso de error
      Future.delayed(const Duration(seconds: 5), _initializeConnection);
    });
  }

  static void ensureConnection() {
    if (_channel == null || _channel!.closeCode != null) {
      _initializeConnection();
    }
  }

  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _deviceId = null;
  }
}