import 'package:flutter/material.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/services/local_storage_service.dart';
import 'package:notification_app/features/home/presentation/widgets/dashboard_card.dart';
import 'package:notification_app/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await ApiService.getCurrentUser();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar el usuario')),
      );
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
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido, ${currentUser!.nombre}',
              style: const TextStyle(
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
                  if (currentUser!.esAdmin)
                    DashboardCard(
                      title: 'Administrar Usuarios',
                      value: 'Gestionar',
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

  Future<void> _logout() async {
    await LocalStorageService.remove('access_token');
    await LocalStorageService.remove('refresh_token');
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
