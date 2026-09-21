class RegistroEjercicio {
  final String id;
  String ejercicioId;
  DateTime fecha;
  bool completado;

  RegistroEjercicio({
    required this.id,
    required this.ejercicioId,
    required this.fecha,
    required this.completado,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ejercicioId': ejercicioId,
        'fecha': fecha.toIso8601String(),
        'completado': completado,
      };

  factory RegistroEjercicio.fromJson(Map<String, dynamic> json) {
    return RegistroEjercicio(
      id: json['id'],
      ejercicioId: json['ejercicioId'],
      fecha: DateTime.parse(json['fecha']),
      completado: json['completado'],
    );
  }
}
