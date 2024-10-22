import 'package:flutter/material.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AddDeviceDialog extends StatefulWidget {
  final VoidCallback onDeviceAdded;

  const AddDeviceDialog({
    super.key,
    required this.onDeviceAdded,
  });

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  bool _isLoading = false;
  String _deviceModel = '';
  String _deviceOS = '';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _deviceModel = androidInfo.model;
        _deviceOS = 'Android ${androidInfo.version.release}';
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        _deviceModel = iosInfo.model;
        _deviceOS = iosInfo.systemVersion;
      });
    }
  }

  Future<void> _registerDevice() async {
    setState(() => _isLoading = true);
    try {
      // En una implementación real, aquí obtendrías el token de Firebase o el servicio de notificaciones que uses
      final deviceToken = 'sample-token-${DateTime.now().millisecondsSinceEpoch}';

      await ApiService.registerDevice(
        token: deviceToken,
        modelo: _deviceModel,
        sistemaOperativo: _deviceOS,
      );

      Navigator.pop(context);
      widget.onDeviceAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo registrado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar dispositivo: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Dispositivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modelo: $_deviceModel'),
          const SizedBox(height: 8),
          Text('Sistema Operativo: $_deviceOS'),
          const SizedBox(height: 16),
          const Text(
            'Se registrará este dispositivo para recibir notificaciones. '
                '¿Desea continuar?',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerDevice,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Registrar'),
        ),
      ],
    );
  }
}