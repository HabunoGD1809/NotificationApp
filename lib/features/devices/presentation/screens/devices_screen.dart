import 'package:flutter/material.dart';
import 'package:notification_app/models/device.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:notification_app/features/devices/presentation/widgets/add_device_dialog.dart';

class DevicesScreen extends StatefulWidget {
  final String userId;

  const DevicesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await ApiService.getUserDevices(widget.userId);
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar dispositivos: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDevice(Device device) async {
    try {
      await ApiService.deleteDevice(device.id);
      await _loadDevices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar dispositivo: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Dispositivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDeviceDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            leading: Icon(
              Icons.phone_android,
              color: device.estaOnline ? Colors.green : Colors.grey,
            ),
            title: Text('${device.modelo} (${device.sistemaOperativo})'),
            subtitle: Text(device.estaOnline ? 'En línea' : 'Desconectado'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmDialog(device),
            ),
          );
        },
      ),
    );
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddDeviceDialog(
        onDeviceAdded: _loadDevices,
      ),
    );
  }

  void _showDeleteConfirmDialog(Device device) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Está seguro que desea eliminar este dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDevice(device);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}