import 'package:flutter/material.dart';
import 'package:notification_app/models/user.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/core/widgets/loading_indicator.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Usuarios')),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user.nombre),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _showSendNotificationDialog(user),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showSendNotificationDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String body = '';
        return AlertDialog(
          title: Text('Enviar Notificación a ${user.nombre}'),
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
                    await ApiService.sendNotificationToUser(user.id, title, body);
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
}