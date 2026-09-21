enum TipoAlimento {
  liquido,
  solido,
  plato,
}

class AlimentoRegistro {
  final String id;
  String descripcion;
  TipoAlimento tipo;
  double cantidad;
  DateTime fechaHora;

  AlimentoRegistro({
    required this.id,
    required this.descripcion,
    required this.tipo,
    required this.cantidad,
    required this.fechaHora,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'tipo': tipo.name,
        'cantidad': cantidad,
        'fechaHora': fechaHora.toIso8601String(),
      };

  factory AlimentoRegistro.fromJson(Map<String, dynamic> json) {
    return AlimentoRegistro(
      id: json['id'],
      descripcion: json['descripcion'],
      tipo: TipoAlimento.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoAlimento.solido,
      ),
      cantidad: (json['cantidad'] as num).toDouble(),
      fechaHora: DateTime.parse(json['fechaHora']),
    );
  }
}
