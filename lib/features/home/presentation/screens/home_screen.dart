import 'package:flutter/material.dart';
import 'package:notification_app/services/local_storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido a la aplicación de notificaciones'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/notifications'),
              child: const Text('Ver Notificaciones'),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalStorageService.remove('user_id');
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}