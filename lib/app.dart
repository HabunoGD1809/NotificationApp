import 'package:flutter/material.dart';
import 'package:notification_app/config/theme.dart';
import 'package:notification_app/config/routes.dart';
import 'package:notification_app/features/auth/presentation/screens/login_screen.dart';
import 'package:notification_app/services/local_storage_service.dart';

import 'features/home/presentation/screens/home_screen.dart';

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: FutureBuilder<String?>(
        future: LocalStorageService.getString('access_token'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}