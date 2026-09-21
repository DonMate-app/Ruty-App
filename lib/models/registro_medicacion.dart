class RegistroMedicacion {
  final String id;
  String medicamentoId;
  DateTime fechaHora;
  bool tomado;

  RegistroMedicacion({
    required this.id,
    required this.medicamentoId,
    required this.fechaHora,
    required this.tomado,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicamentoId': medicamentoId,
        'fechaHora': fechaHora.toIso8601String(),
        'tomado': tomado,
      };

  factory RegistroMedicacion.fromJson(Map<String, dynamic> json) {
    return RegistroMedicacion(
      id: json['id'],
      medicamentoId: json['medicamentoId'],
      fechaHora: DateTime.parse(json['fechaHora']),
      tomado: json['tomado'],
    );
  }
}
