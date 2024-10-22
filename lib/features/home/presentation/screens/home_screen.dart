import 'package:flutter/material.dart';
import 'package:notification_app/features/home/presentation/widgets/dashboard_card.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/services/local_storage_service.dart';
import 'package:notification_app/services/websocket_service.dart';
import 'package:notification_app/models/user.dart';
import 'package:notification_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:notification_app/features/devices/presentation/screens/devices_screen.dart';
import 'package:notification_app/features/settings/presentation/screens/sound_settings_screen.dart';
import 'package:notification_app/features/admin/presentation/screens/admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ApiService.getCurrentUser();
      final token = LocalStorageService.getString('access_token');

      if (token == null) {
        throw Exception('No se encontró el token de acceso');
      }

      setState(() {
        _currentUser = user;
        _isAdmin = user.esAdmin;
        _isLoading = false;
      });

      // Conectar WebSocket con el token
      print('Conectando WebSocket para usuario: ${user.id}'); // Debug log
      WebSocketService.connect(user.id, token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos del usuario: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAdmin ? _buildAdminHome() : _buildUserHome();
  }

  Widget _buildAdminHome() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: _buildAppBarActions(),
      ),
      body: const AdminDashboardScreen(),
    );
  }

  Widget _buildUserHome() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${_currentUser?.nombre ?? ""}'),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Mis Notificaciones',
                    value: 'Ver todas',
                    icon: Icons.notifications,
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  DashboardCard(
                    title: 'Mis Dispositivos',
                    value: 'Gestionar',
                    icon: Icons.devices,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevicesScreen(userId: _currentUser!.id),
                      ),
                    ),
                  ),
                  DashboardCard(
                    title: 'Configuración',
                    value: 'Sonidos y más',
                    icon: Icons.settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SoundSettingsScreen(userId: _currentUser!.id),
                      ),
                    ),
                  ),
                  DashboardCard(
                    title: 'Mi Perfil',
                    value: 'Ver detalles',
                    icon: Icons.person,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(user: _currentUser!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.exit_to_app),
        onPressed: _logout,
        tooltip: 'Cerrar sesión',
      ),
    ];
  }

  Future<void> _logout() async {
    try {
      WebSocketService.disconnect(); // Desconectar WebSocket antes de limpiar tokens
      await LocalStorageService.remove('access_token');
      await LocalStorageService.remove('refresh_token');
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