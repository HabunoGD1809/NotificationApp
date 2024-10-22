import 'package:flutter/material.dart';
import 'package:notification_app/models/device.dart';
import 'package:notification_app/models/user.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/features/admin/presentation/widgets/admin_notification_dialog.dart';
import 'package:notification_app/features/admin/presentation/widgets/statistics_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _statistics = {};
  List<User> _users = [];
  List<Device> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await ApiService.getNotificationStatistics();
      final users = await ApiService.getUsers();
      final devices = await ApiService.getDevices();

      setState(() {
        _statistics = stats;
        _users = users;
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Estadísticas'),
              Tab(text: 'Usuarios'),
              Tab(text: 'Dispositivos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStatisticsTab(),
                _buildUsersTab(),
                _buildDevicesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatisticsCard(
          title: 'Total Notificaciones',
          value: _statistics['total_notificaciones']?.toString() ?? '0',
          icon: Icons.notifications,
        ),
        StatisticsCard(
          title: 'Notificaciones Enviadas',
          value: _statistics['notificaciones_enviadas']?.toString() ?? '0',
          icon: Icons.send,
        ),
        StatisticsCard(
          title: 'Notificaciones Leídas',
          value: _statistics['notificaciones_leidas']?.toString() ?? '0',
          icon: Icons.mark_email_read,
        ),
        StatisticsCard(
          title: 'Dispositivos Activos',
          value: _statistics['dispositivos_activos']?.toString() ?? '0',
          icon: Icons.devices,
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          title: Text(user.nombre),
          subtitle: Text(user.email),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _showSendNotificationDialog(user: user),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showUserOptionsDialog(user),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDevicesTab() {
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return ListTile(
          title: Text('${device.modelo} (${device.sistemaOperativo})'),
          subtitle: Text(device.estaOnline ? 'En línea' : 'Desconectado'),
          trailing: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _showSendNotificationDialog(device: device),
          ),
        );
      },
    );
  }

  void _showSendNotificationDialog({User? user, Device? device}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminNotificationDialog(user: user, device: device);
      },
    );
  }

  void _showUserOptionsDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opciones para ${user.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Restablecer Contraseña'),
                onTap: () {
                  Navigator.pop(context);
                  _showResetPasswordDialog(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar Usuario'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteUserDialog(user);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showResetPasswordDialog(User user) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restablecer Contraseña - ${user.nombre}'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.resetUserPassword(
                    user.id,
                    passwordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña restablecida con éxito')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro que desea eliminar al usuario ${user.nombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.deleteUser(user.id);
                  Navigator.pop(context);
                  _loadData(); // Recargar datos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario eliminado con éxito')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
