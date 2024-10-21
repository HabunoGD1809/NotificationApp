class NotificationModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String? imagenUrl;
  final DateTime fechaCreacion;
  final bool leida;

  NotificationModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    this.imagenUrl,
    required this.fechaCreacion,
    required this.leida,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      imagenUrl: json['imagen_url'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      leida: json['leida'],
    );
  }
}
