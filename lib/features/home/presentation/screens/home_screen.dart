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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _checkAdminStatus();
      await _connectWebSocket();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al inicializar: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = await ApiService.getCurrentUser();
      setState(() {
        _isAdmin = user.esAdmin;
        _userId = user.id;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener información del usuario: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final token = LocalStorageService.getString('access_token');
      if (token != null && _userId.isNotEmpty) {
        print('Conectando WebSocket con userId: $_userId'); // Debug log
        WebSocketService.connect(_userId, token);
      } else {
        throw Exception('No se pudo iniciar la conexión WebSocket: token o userId no disponible');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar WebSocket: ${e.toString()}')),
        );
      }
    }
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
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificación enviada con éxito')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al enviar notificación: ${e.toString()}')),
                      );
                    }
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
    try {
      await LocalStorageService.remove('access_token');
      await LocalStorageService.remove('refresh_token');
      WebSocketService.disconnect();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    WebSocketService.disconnect();
    super.dispose();
  }
}