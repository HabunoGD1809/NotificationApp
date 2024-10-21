import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notification_app/models/user.dart';
import 'package:notification_app/models/notification.dart';
import 'package:notification_app/models/device.dart';
import 'package:notification_app/config/app_config.dart';
import 'package:notification_app/services/local_storage_service.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setToken(data['access_token']);
      await LocalStorageService.setString('access_token', data['access_token']);
      await LocalStorageService.setString('refresh_token', data['refresh_token']);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get current user');
    }
  }

  static Future<bool> checkAndRefreshToken() async {
    final refreshToken = LocalStorageService.getString('refresh_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh'),
        body: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setToken(data['access_token']);
        await LocalStorageService.setString('access_token', data['access_token']);
        await LocalStorageService.setString('refresh_token', data['refresh_token']);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }

    return false;
  }

  static Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get users');
    }
  }

  static Future<List<NotificationModel>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notificaciones'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> notificationsJson = json.decode(response.body);
      return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get notifications');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notificaciones/$notificationId/leer'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  static Future<Device> registerDevice(String token, String model, String os) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dispositivos'),
      headers: await _getHeaders(),
      body: json.encode({
        'token': token,
        'modelo': model,
        'sistema_operativo': os,
      }),
    );

    if (response.statusCode == 200) {
      return Device.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register device');
    }
  }

  static Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dispositivos/$deviceId/online'),
      headers: await _getHeaders(),
      body: json.encode({'esta_online': isOnline}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update device status');
    }
  }
}