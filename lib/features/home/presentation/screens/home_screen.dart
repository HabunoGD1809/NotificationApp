import 'package:flutter/material.dart';
import 'package:notification_app/features/home/presentation/widgets/dashboard_card.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/services/local_storage_service.dart';
import 'package:notification_app/services/websocket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _connectWebSocket();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = await ApiService.getCurrentUser();
      setState(() {
        _isAdmin = user.esAdmin;
        _userId = user.id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener información del usuario: ${e.toString()}')),
      );
    }
  }

  void _connectWebSocket() {
    WebSocketService.connect(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Notificaciones',
                    value: 'Ver todas',
                    icon: Icons.notifications,
                    onTap: () => Navigator.of(context).pushNamed('/notifications'),
                  ),
                  DashboardCard(
                    title: 'Enviar Notificación',
                    value: 'Prueba',
                    icon: Icons.send,
                    onTap: _showSendNotificationDialog,
                  ),
                  if (_isAdmin)
                    DashboardCard(
                      title: 'Administrar Usuarios',
                      value: 'Ver todos',
                      icon: Icons.people,
                      onTap: () => Navigator.of(context).pushNamed('/admin/users'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String body = '';
        return AlertDialog(
          title: const Text('Enviar Notificación de Prueba'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Mensaje'),
                onChanged: (value) => body = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                if (title.isNotEmpty && body.isNotEmpty) {
                  try {
                    await ApiService.createNotification(title, body);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificación enviada con éxito')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al enviar notificación: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await LocalStorageService.remove('access_token');
    await LocalStorageService.remove('refresh_token');
    WebSocketService.disconnect();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
