class Device {
  final String id;
  final String token;
  final bool estaOnline;
  final DateTime ultimoAcceso;
  final String modelo;
  final String sistemaOperativo;

  Device({
    required this.id,
    required this.token,
    required this.estaOnline,
    required this.ultimoAcceso,
    required this.modelo,
    required this.sistemaOperativo,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      token: json['token'],
      estaOnline: json['esta_online'],
      ultimoAcceso: DateTime.parse(json['ultimo_acceso']),
      modelo: json['modelo'],
      sistemaOperativo: json['sistema_operativo'],
    );
  }
}