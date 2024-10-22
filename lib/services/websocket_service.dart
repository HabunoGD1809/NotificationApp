import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:notification_app/config/app_config.dart';
import 'package:notification_app/services/local_notification_service.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static String? _deviceId;
  static String? _token;
  static bool _isConnecting = false;
  static const int _reconnectDelay = 5; // segundos

  static void connect(String deviceId, String token) {
    _deviceId = deviceId;
    _token = token;
    _initializeConnection();
  }

  static void _initializeConnection() async {
    if (_isConnecting || _deviceId == null || _token == null) return;

    try {
      _isConnecting = true;

      // Construir la URL con el token
      final wsUrl = Uri.parse('${AppConfig.wsUrl}/ws/$_deviceId?token=$_token');
      print('Intentando conectar WebSocket a: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
            (message) {
          _handleMessage(message);
        },
        onDone: () {
          print('WebSocket conexión cerrada');
          _isConnecting = false;
          _scheduleReconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnecting = false;
          _scheduleReconnect();
        },
      );

      // Iniciar ping periódico para mantener la conexión viva
      _startPingTimer();

    } catch (e) {
      print('Error al conectar WebSocket: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  static void _handleMessage(dynamic message) {
    try {
      if (message == "pong") {
        // Respuesta al ping, la conexión está viva
        return;
      }

      final data = json.decode(message);
      if (data['tipo'] == 'nueva_notificacion' ||
          data['tipo'] == 'notificacion_pendiente') {
        LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: data['notificacion']['titulo'],
          body: data['notificacion']['mensaje'],
        );
      }
    } catch (e) {
      print('Error procesando mensaje WebSocket: $e');
    }
  }

  static void _startPingTimer() {
    Future.doWhile(() async {
      if (_channel == null) return false;

      try {
        _channel?.sink.add('ping');
      } catch (e) {
        print('Error enviando ping: $e');
        return false;
      }

      await Future.delayed(const Duration(seconds: 30));
      return _channel != null;
    });
  }

  static void _scheduleReconnect() {
    if (_channel == null || _channel!.closeCode != null) {
      Future.delayed(
        const Duration(seconds: _reconnectDelay),
            () => _initializeConnection(),
      );
    }
  }

  static void ensureConnection() {
    if (_channel == null || _channel!.closeCode != null) {
      _initializeConnection();
    }
  }

  static void disconnect() {
    try {
      _channel?.sink.close();
    } catch (e) {
      print('Error al cerrar WebSocket: $e');
    } finally {
      _channel = null;
      _deviceId = null;
      _token = null;
      _isConnecting = false;
    }
  }
}