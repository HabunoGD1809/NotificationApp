import 'package:flutter/material.dart';
import 'package:notification_app/features/auth/presentation/screens/login_screen.dart';
import 'package:notification_app/features/home/presentation/screens/home_screen.dart';
import 'package:notification_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:notification_app/features/admin/presentation/screens/admin_users_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/notifications': (context) => const NotificationsScreen(),
    '/admin/users': (context) => const AdminUsersScreen(),
  };
}