enum TipoComentario {
  sugerencia,
  error,
  felicitacion,
  otro,
}

class ComentarioUsuario {
  final String id;
  final TipoComentario tipo;
  final String mensaje;
  final String contacto;
  final DateTime fecha;
  final String versionApp;
  bool enviado;

  ComentarioUsuario({
    required this.id,
    required this.tipo,
    required this.mensaje,
    required this.contacto,
    required this.fecha,
    required this.versionApp,
    this.enviado = false,
  });

  String get etiquetaTipo {
    switch (tipo) {
      case TipoComentario.sugerencia:
        return 'Sugerencia';
      case TipoComentario.error:
        return 'Error';
      case TipoComentario.felicitacion:
        return 'Felicitación';
      case TipoComentario.otro:
        return 'Otro';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name,
        'mensaje': mensaje,
        'contacto': contacto,
        'fecha': fecha.toIso8601String(),
        'versionApp': versionApp,
        'enviado': enviado,
      };

  factory ComentarioUsuario.fromJson(Map<String, dynamic> json) {
    return ComentarioUsuario(
      id: json['id'],
      tipo: TipoComentario.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoComentario.otro,
      ),
      mensaje: json['mensaje'],
      contacto: json['contacto'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      versionApp: json['versionApp'] ?? '',
      enviado: json['enviado'] ?? false,
    );
  }
}
