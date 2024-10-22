import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:notification_app/config/app_config.dart';
import 'package:notification_app/models/user.dart';
import 'package:notification_app/models/notification.dart';
import 'package:notification_app/models/device.dart';
import 'package:notification_app/services/local_storage_service.dart';

class ApiService {
  static Future<String> _getToken() async {
    final token = LocalStorageService.getString('access_token');
    if (token == null) {
      throw Exception('No se encontró el token de acceso');
    }
    return token;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expirado, intentar renovar
      await refreshToken();
      throw Exception('Token expirado, por favor intente de nuevo');
    } else {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  }

  static Future<void> refreshToken() async {
    final refreshToken = LocalStorageService.getString('refresh_token');
    if (refreshToken == null) {
      throw Exception('No se encontró el token de refresco');
    }

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/token/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await LocalStorageService.setString('access_token', data['access_token']);
      await LocalStorageService.setString(
          'refresh_token', data['refresh_token']);
    } else {
      throw Exception('Error al renovar el token');
    }
  }

  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<User> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/me'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  static Future<List<NotificationModel>> getNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return (data as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones/$notificationId/leer'),
      headers: headers,
    );
    await _handleResponse(response);
  }

  // en revision
  static Future<void> createNotification({
    required String title,
    required String body,
    String? imageUrl,
    List<String>? dispositivosObjetivo,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones'),
      headers: headers,
      body: json.encode({
        'titulo': title,
        'mensaje': body,
        if (imageUrl != null) 'imagenUrl': imageUrl,
        if (dispositivosObjetivo != null) 'dispositivosObjetivo': dispositivosObjetivo,
      }),
    );
    await _handleResponse(response);
  }

  static Future<List<User>> getUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((item) => User.fromJson(item)).toList();
  }

  static Future<void> sendNotificationToUser(
      String userId, String title, String body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones'),
      headers: headers,
      body: json.encode({
        'titulo': title,
        'mensaje': body,
        'dispositivos_objetivo': [userId],
      }),
    );
    await _handleResponse(response);
  }

  static Future<List<Device>> getDevices() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/dispositivos'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((item) => Device.fromJson(item)).toList();
  }

  static Future<void> updateDeviceToken(
      String deviceId, String newToken) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/dispositivos/$deviceId/token'),
      headers: headers,
      body: json.encode({'nuevo_token': newToken}),
    );
    await _handleResponse(response);
  }

  static Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/dispositivos/$deviceId/online'),
      headers: headers,
      body: json.encode({'esta_online': isOnline}),
    );
    await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getNotificationStatistics() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones/estadisticas'),
      headers: headers,
    );
    return await _handleResponse(response);
  }

  static Future<void> resendNotification(String notificationId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/notificaciones/$notificationId/reenviar'),
      headers: headers,
    );
    await _handleResponse(response);
  }

  static Future<void> setNotificationSound(String sound) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/configuracion-sonido'),
      headers: headers,
      body: json.encode({'sonido': sound}),
    );
    await _handleResponse(response);
  }

  static Future<String> getNotificationSound() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/configuracion-sonido'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return data['sonido'];
  }

  static Future<void> deleteUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/$userId'),
      headers: headers,
    );
    await _handleResponse(response);
  }

  static Future<void> changePassword(String newPassword) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/cambiar_contrasena'),
      headers: headers,
      body: json.encode({'nueva_contrasena': newPassword}),
    );
    await _handleResponse(response);
  }

  static Future<void> resetUserPassword(
      String userId, String newPassword) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/usuarios/$userId/restablecer_contrasena'),
      headers: headers,
      body: json.encode({'nueva_contrasena': newPassword}),
    );
    await _handleResponse(response);
  }

  static Future<void> deleteDevice(String deviceId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/dispositivos/$deviceId'),
      headers: headers,
    );
    await _handleResponse(response);
  }

  static Future<void> deleteNotification(String notificationId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/notificaciones/$notificationId'),
      headers: headers,
    );
    await _handleResponse(response);
  }

  static Future<void> uploadImage(File imageFile) async {
    final headers = await _getHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/upload-image'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    request.headers.addAll(headers);

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al subir la imagen');
    }
  }

  static Future<List<Device>> getUserDevices(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/$userId/dispositivos'),
      headers: headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((item) => Device.fromJson(item)).toList();
  }

  static Future<void> registerDevice({
    required String token,
    required String modelo,
    required String sistemaOperativo,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/dispositivos'),
      headers: headers,
      body: json.encode({
        'token': token,
        'modelo': modelo,
        'sistema_operativo': sistemaOperativo,
      }),
    );
    await _handleResponse(response);
  }
}
