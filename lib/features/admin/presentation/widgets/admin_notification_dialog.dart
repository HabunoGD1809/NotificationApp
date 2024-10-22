import 'package:flutter/material.dart';
import 'package:notification_app/models/user.dart';
import 'package:notification_app/models/device.dart';
import 'package:notification_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminNotificationDialog extends StatefulWidget {
  final User? user;
  final Device? device;

  const AdminNotificationDialog({
    super.key,
    this.user,
    this.device,
  });

  @override
  State<AdminNotificationDialog> createState() =>
      _AdminNotificationDialogState();
}

class _AdminNotificationDialogState extends State<AdminNotificationDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  File? _imageFile;
  late bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Enviar Notificación a ${widget.user?.nombre ?? "dispositivo"}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Añadir Imagen'),
                  onPressed: _pickImage,
                ),
                if (_imageFile != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
                ],
              ],
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.file(
                  _imageFile!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendNotification,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        // Aquí implementarías la lógica para subir la imagen y obtener su URL
        // imageUrl = await ApiService.uploadImage(_imageFile!);
      }

      // en revision
      await ApiService.createNotification(
        title: _titleController.text,
        body: _messageController.text,
        imageUrl: imageUrl,
        dispositivosObjetivo: widget.device != null
            ? [widget.device!.id]
            : widget.user != null
            ? [widget.user!.id]
            : null,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación enviada con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al enviar la notificación: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
