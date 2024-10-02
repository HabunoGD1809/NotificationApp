import 'package:flutter/material.dart';
import 'package:notification_app/config/theme.dart';
import 'package:notification_app/config/routes.dart';
import 'package:notification_app/features/auth/presentation/screens/login_screen.dart';

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}